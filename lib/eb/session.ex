defmodule EB.Session do
  use GenServer,
    start: {__MODULE__, :start_link, []},
    restart: :temporary

  def start_link(user_id) do
    name = {:via, Registry, {EB.Session.Registry, user_id}}
    {:ok, pid} = GenServer.start_link(__MODULE__, user_id, name: name)
    GenServer.cast(pid, :load_user)

    {:ok, pid}
  end

  def put_user(pid, user) do
    GenServer.cast(pid, {:put_user, user})
  end

  def process(pid, xp) do
    GenServer.cast(pid, {:process, xp})
  end

  def lookup(user_id) do
    case Registry.lookup(EB.Session.Registry, user_id) do
      [] -> nil
      [{pid, _}] -> pid
    end
  end

  def debug(user_id) do
    case lookup(user_id) do
      nil -> nil
      pid -> :sys.get_state(pid)
    end
  end

  def debug_random do
    EB.Session.Supervisor
    |> Supervisor.which_children
    |> Enum.random
    |> elem(1)
    |> :sys.get_state
  end

  def init(user_id) do
    {:ok, %{user: %EB.User{id: user_id}, queue: :queue.new, state: :loading_user}}
  end

  def handle_cast(
    :load_user,
    %{user: %EB.User{id: user_id}, state: :loading_user} = session
  ) do
    EB.User.Loader.load(user_id)
    {:noreply, session}
  end
  def handle_cast(
    {:put_user, user},
    %{state: :loading_user, queue: queue} = session
  ) do
    {
      :noreply,
      %{session |
        user: process_queue(user, queue),
        queue: nil,
        state: :processing
      }
    }
  end
  def handle_cast(
    {:process, xp},
    %{state: :loading_user, queue: queue} = session
  ) do
    {:noreply, %{session | queue: :queue.in(xp, queue)}}
  end
  def handle_cast({:process, xp}, %{state: :processing, user: user} = session) do
    {:noreply, %{session | user: process_xp(user, xp)}}
  end

  defp process_queue(user, queue) do
    case :queue.out(queue) do
      {:empty, _} -> user
      {{:value, xp}, queue} -> process_queue(process_xp(user, xp), queue)
    end
  end

  defp process_xp(user, xp) do
    Map.update!(user, :xp_required, &(&1 - xp))
    |> process_level
  end

  defp process_level(%{xp_required: xp_required} = user)
  when xp_required <= 0 do
    level = user.level + 1
    xp_required = level * level * 10 + 10
    %{user | level: level, xp_required: xp_required}
  end
  defp process_level(user), do: user
end
