defmodule EB.User.Loader.Supervisor do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init(
      [
        EB.User.Loader.Producer,
        EB.User.Loader.Collector,
        EB.User.Loader.Consumer
      ],
      strategy: :one_for_one
    )
  end
end