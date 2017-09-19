defmodule EB.User.Worker do
  def start_link(job) do
    # job: [{id1, pid1}, {id2, pid2}, ...]
    Task.start_link(fn ->
      with user_hash <- user_hash(job) do
        # user_hash: %{id1 => %{id: id1, required_xp: xp, ...}, ...}
        Enum.map(job, fn({id, pid}) ->
          with user <- Map.get(user_hash, id) do
            EB.Session.put_user(pid, user)
          end
        end)
      end
    end)
  end

  defp user_hash(job) do
    job
    |> users
    |> Enum.map(&{&1.id, &1})
    |> Enum.into(%{})
  end

  defp users(job) do
    job
    |> Enum.map(fn({id, _}) -> id end)
    |> EB.User.by_ids
  end
end
