defmodule EB.Dispatcher do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, nil, 0}
  end

  def handle_info(:timeout, state) do
    # Generate random event for random user: {user_id, xp}
    {user_id, xp} = {:rand.uniform(5_000), :rand.uniform(10)}

    user_id
    |> lookup_or_start
    |> EB.Session.process(xp)

    Process.send_after(self(), :timeout, :rand.uniform(3))

    {:noreply, state}
  end

  defp lookup_or_start(user_id) do
    case EB.Session.lookup(user_id) do
      nil ->
        {:ok, pid} = EB.Session.Supervisor.start_child(user_id)
        pid
      pid ->
        pid
    end
  end
end
