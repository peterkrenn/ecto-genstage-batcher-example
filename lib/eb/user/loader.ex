defmodule EB.User.Loader do
  use GenStage

  def start_link([]) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def load(id) do
    GenServer.cast(__MODULE__, {:load, id, self()})
  end

  def init(:ok) do
    {:producer, {:queue.new, 0}}
  end

  def handle_cast({:load, id, from}, {queue, demand}) do
    dispatch_jobs(:queue.in({id, from}, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_jobs(queue, incoming_demand + demand, [])
  end

  defp dispatch_jobs(queue, 0, jobs) do
    {:noreply, Enum.reverse(jobs), {queue, 0}}
  end
  defp dispatch_jobs(queue, demand, jobs) do
    case :queue.out(queue) do
      {{:value, job}, queue} ->
        dispatch_jobs(queue, demand - 1, [job | jobs])
      {:empty, queue} ->
        {:noreply, Enum.reverse(jobs), {queue, demand}}
    end
  end
end
