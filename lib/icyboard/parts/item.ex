defmodule Icyboard.Parts.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Icyboard.Repo
  alias Icyboard.Parts

  @primary_key {:code, :string, []}
  @derive {Phoenix.Param, key: :code}
  schema "items" do
    field :type, Ecto.Enum, values: [:epic, :story, :task, :bug, :subtask]
    field :state, Ecto.Enum, values: [:todo, :active, :done], default: :todo
    field :priority, Ecto.Enum, values: [:low, :normal, :high, :urgent], default: :normal
    field :title, :string
    field :description, :string
    field :reported_by, :integer
    field :updated_by, :integer
    field :project, :string
    field :parent, :string
    field :epic, :string

    timestamps()
  end

  @doc false
  def changeset(items, attrs) do
    items
    |> cast(attrs, [:code, :project, :priority, :type, :title, :description, :reported_by, :updated_by, :parent, :epic])
    |> validate_required([:code, :project, :type, :title])
    |> validate_length(:code, min: 2, max: 10)
    |> validate_length(:title, min: 3, max: 240)
    |> validate_item_type()
    |> validate_item_parent_type()
    |> validate_item_epic_type()
    |> validate_item_parent()
  end

  def state_changeset(item, attrs) do
    item
    |> cast(attrs, [:state, :updated_by])
    |> validate_required([:state])
  end

  def title_changeset(item, attrs) do
    item
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> validate_length(:title, min: 3, max: 240)
  end

  defp validate_item_parent_type(changeset) do
    validate_change changeset, :parent, fn _field, _value ->
      change = get_change changeset, :parent

      if change != nil do
        validate_types changeset, :parent
      else
        []
      end
    end
  end

  defp validate_item_epic_type(changeset) do
    validate_change changeset, :epic, fn _field, _value ->
      change = get_change changeset, :epic

      if change != nil do
        validate_types changeset, :epic
      else
        []
      end
    end
  end

  defp validate_item_type(changeset) do
    validate_change changeset, :type, fn _field, _value ->
      change = get_change changeset, :type

      if change != nil do
        validate_types changeset, :type
      else
        []
      end
    end
  end

  defp validate_item_parent(changeset) do
    validate_change changeset, :parent, fn _field, value ->
      change = get_change changeset, :parent

      if value != nil and change != nil do
        parent = Repo.get Item, (get_field changeset, :parent)
        epic = get_field changeset, :epic
        project = get_field changeset, :project

        cond do
          parent.epic != epic ->
            [:parent, "parent cannot be in different epic"]

          parent.project != project ->
            [:parent, "parent cannot be in different project"]

          true ->
            []
        end
      else
        []
      end
    end
  end

  defp get_parent_type(changeset) do
    id = get_field changeset, :parent

    if id == nil do
      nil
    else
      parent = Parts.get_item! id

      if parent == nil do
        nil
      else
        parent.type
      end
    end
  end

  defp validate_types(changeset, field) do
      epic = get_field changeset, :epic
      self = get_field changeset, :type
      parent = get_parent_type changeset

      cond do
        # epics
        self == :epic and epic != nil  and field == :epic ->
          [{field, "epic must not link to epic"}]
        self == :epic and parent != nil and field == :epic ->
          [{field, "epic must not have parent"}]

        # stories
        self == :story and parent == :task and field == :type ->
          [{field, "story must not have task parent"}]
        self == :story and parent == :bug and field == :type ->
          [{field, "story must not have bug parent"}]

        # subtasks
        self == :subtask and parent != :task and field == :type ->
          [{field, "subtask must have task parent"}]

        # general
        parent == :subtask and field == :type ->
          [{field, "must not use subtask as parent"}]
        true ->
          []
      end
  end
end
