defmodule Icyboard.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :text

      timestamps()
    end

    unique_index(:projects, [:code])
  end
end
