defmodule EB.Session.Supervisor do
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(user_id) do
    Supervisor.start_child(__MODULE__, [user_id])
  end

  def terminate_children do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.map(fn({_, pid, _, _}) ->
      Supervisor.terminate_child(__MODULE__, pid)
    end)
  end

  def init(:ok) do
    Supervisor.init([EB.Session], strategy: :simple_one_for_one)
  end
end
