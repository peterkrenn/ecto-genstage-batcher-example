Ecto.Adapters.SQL.query!(EB.Repo, "TRUNCATE TABLE users RESTART IDENTITY", [])

EB.Repo.insert_all(
  EB.User,
  1..5_000
  |> Enum.map(fn(_) -> :rand.uniform(50) end)
  |> Enum.map(fn(level) ->
    %{
      level: level,
      xp_required: :rand.uniform(level * level * 10 + 10)
    }
  end)
)
