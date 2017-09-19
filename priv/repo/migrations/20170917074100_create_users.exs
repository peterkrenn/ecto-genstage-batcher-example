defmodule EB.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :level, :integer, default: 1
      add :xp_required, :integer, default: 19
    end
  end
end
