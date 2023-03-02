defmodule Icyboard.Parts do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Icyboard.Repo

  alias Icyboard.Parts.Project
  alias Icyboard.Parts.Item

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(code), do: Repo.get!(Project, code)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  def list_items(type) do
    Repo.all(from item in Item,
             where: item.type == ^type,
             order_by: [desc: :updated_at])
  end

  def list_items_in_project(project_code, type \\ :any) do
    if type == :any do
      Repo.all(from item in Item,
               where: item.project == ^project_code,
               order_by: [desc: :updated_at])
    else
      Repo.all(from item in Item,
               where: item.project == ^project_code and item.type == ^type,
               order_by: [desc: :updated_at])
    end
  end

  def list_items_in_epic(epic_code, type \\ :any) do
    if type == :any do
      Repo.all(from item in Item,
               where: item.epic == ^epic_code,
               order_by: [asc: :inserted_at])
    else
      Repo.all(from item in Item,
               where: item.epic == ^epic_code and item.type == ^type,
               order_by: [asc: :inserted_at])
    end
  end

  def list_items_in_parent(code, type \\ :any) do
    if type == :any do
      Repo.all(from item in Item,
               where: item.parent == ^code,
               order_by: [asc: :inserted_at])
    else
      Repo.all(from item in Item,
               where: item.parent == ^code and item.type == ^type,
               order_by: [asc: :inserted_at])
    end
  end

  def get_item!(code), do: Repo.get! Item, code

  def get_item(code), do: if code == nil, do: nil, else: (Repo.get Item, code)

  def create_item(attrs \\ %{}, user_id) do
    project_code = attrs["project"]
    multi_struct = Multi.new
    |> Multi.one(:project, (from project in Project, where: project.code == ^project_code, lock: "FOR UPDATE"))
    |> Multi.run(:item, fn _repo, %{project: project} ->
      padded_number = project.counter + 1
      |> Integer.to_string()
      |> String.pad_leading(4, "0")
      merged_attrs = %{attrs | "code" => "#{project.code}-#{padded_number}"}
      merged_attrs = %{merged_attrs | "reported_by" => user_id}
      merged_attrs = %{merged_attrs | "updated_by" => user_id}

      %Item{}
      |> Item.changeset(merged_attrs)
      |> Repo.insert()
    end)
    |> Multi.update(:counter, fn %{project: project} ->
      Ecto.Changeset.change(project, counter: project.counter + 1)
    end)

    case Repo.transaction(multi_struct) do
      {:ok, %{item: item, counter: _, project: _}} ->
        {:ok, item}

      {:error, :project, _error, _changes} ->
        changeset = Item.changeset(%Item{}, attrs)
        |> Ecto.Changeset.add_error(:project, "no such project")
        {:error, changeset}

      {:error, :item, changeset, _changes} ->
        {:error, changeset}

      {:error, :counter, _error, _changes} ->
        changeset = Item.changeset(%Item{}, attrs)
        |> Ecto.Changeset.add_error(:code, "could not update project counter")
        {:error, changeset}
    end
  end

  def update_item(%Item{} = item, attrs, user_id) do
    item
    |> Item.changeset(%{attrs | "updated_by" => user_id})
    |> Repo.update()
  end

  def apply_item_state(%Item{} = item, state, user_id) do
    item
    |> Item.state_changeset(%{state: state, updated_by: user_id})
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
