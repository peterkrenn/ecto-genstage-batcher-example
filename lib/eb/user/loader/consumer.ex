defmodule EB.User.Loader.Consumer do
  use ConsumerSupervisor

  def start_link([]) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {
      :ok,
      [worker(EB.User.Loader.Worker, [], restart: :temporary)],
      strategy: :one_for_one,
      subscribe_to: [{EB.User.Loader.Collector, min_demand: 1, max_demand: 5}]
    }
  end
end
