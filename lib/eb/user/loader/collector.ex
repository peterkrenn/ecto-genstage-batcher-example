defmodule EB.User.Loader.Collector do
  use GenStage

  def start_link([]) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {
      :producer_consumer,
      nil,
      subscribe_to: [{EB.User.Loader.Producer, max_demand: 500, interval: 500}]
    }
  end

  def handle_subscribe(:producer, options, from, nil) do
    %{
      producer: from,
      demand: options[:max_demand],
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

  def handle_events(events, _from, %{demand: demand, buffer: buffer} = state) do
    {
      :noreply,
      [],
      %{state | demand: demand + length(events), buffer: buffer ++ events}
    }
  end

  def handle_info(:ask, %{buffer: []} = state) do
    {:noreply, [], ask_and_schedule(state)}
  end
  def handle_info(:ask, %{buffer: buffer} = state) do
    {:noreply, [buffer], ask_and_schedule(%{state | buffer: []})}
  end

  defp ask_and_schedule(
    %{producer: producer, demand: demand, interval: interval} = state
  ) do
    GenStage.ask(producer, demand)
    Process.send_after(self(), :ask, interval)
    %{state | demand: 0}
  end
end
