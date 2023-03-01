defmodule Icyboard.Repo.Migrations.AddItemsStateColumn do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :state, :string, default: "todo"
    end
  end
end
