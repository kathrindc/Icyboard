defmodule Icyboard.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :code, :string, primary_key: true
      add :type, :string
      add :title, :text
      add :description, :text
      add :project, references(:projects, on_delete: :delete_all, column: :code, type: :string)
      add :reported_by, references(:users, on_delete: :nilify_all)
      add :updated_by, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    alter table(:items) do
      add :parent, references(:items, on_delete: :delete_all, column: :code, type: :string)
      add :epic, references(:items, on_delete: :delete_all, column: :code, type: :string)
    end

    create index(:items, [:project])
    create index(:items, [:project, :epic])
  end
end
