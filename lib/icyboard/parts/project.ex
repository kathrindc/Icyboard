defmodule Icyboard.Parts.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:code, :string, []}
  @derive {Phoenix.Param, key: :code}
  schema "projects" do
    field :name, :string
    field :counter, :integer

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> validate_length(:code, min: 2, max: 10)
    |> validate_length(:name, min: 3, max: 240)
    |> validate_format(:code, ~r/^[a-zA-Z0-9]+$/)
  end
end
