defmodule EB.User.Batcher do
  use GenStage

  def start_link([]) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {
      :producer_consumer,
      nil,
      subscribe_to: [{EB.User.Loader, max_demand: 500, interval: 500}]
    }
  end

  def handle_subscribe(:producer, options, from, nil) do
    %{
      producer: from,
      pending: options[:max_demand],
      interval: options[:interval],
      buffer: []
    }
    |> ask_and_schedule
    |> (&{:manual, &1}).()
  end
  def handle_subscribe(:consumer, _options, _from, state) do
    {:automatic, state}
  end

  def handle_cancel(_reason, _from, _state) do
    {:noreply, [], nil}
  end

  def handle_events(events, _from, %{pending: pending, buffer: buffer} = state) do
    {
      :noreply,
      [],
      %{state | pending: pending + length(events), buffer: buffer ++ events}
    }
  end

  def handle_info(:ask, %{buffer: []} = state) do
    {:noreply, [], ask_and_schedule(state)}
  end
  def handle_info(:ask, %{buffer: buffer} = state) do
    {:noreply, [buffer], ask_and_schedule(%{state | buffer: []})}
  end

  defp ask_and_schedule(
    %{producer: producer, pending: pending, interval: interval} = state
  ) do
    GenStage.ask(producer, pending)
    Process.send_after(self(), :ask, interval)
    %{state | pending: 0}
  end
end
