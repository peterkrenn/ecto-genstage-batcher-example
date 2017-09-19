defmodule EB.User do
  use Ecto.Schema
  import Ecto.Query

  schema "users" do
    field :level, :integer
    field :xp_required, :integer
  end

  def by_ids(ids) do
    __MODULE__
    |> where([user], user.id in ^ids)
    |> EB.Repo.all
  end
end
