defmodule Icyboard.Repo.Migrations.AddItemsPriorityColumn do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :priority, :string, default: "normal"
    end
  end
end
