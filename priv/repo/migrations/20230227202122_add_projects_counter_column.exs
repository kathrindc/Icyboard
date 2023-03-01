defmodule Icyboard.Repo.Migrations.AddProjectsCounterColumn do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :counter, :integer, default: 0
    end
  end
end
