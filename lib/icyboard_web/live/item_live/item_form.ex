defmodule IcyboardWeb.ItemLive.ItemForm do
  use IcyboardWeb, :live_component

  alias Icyboard.Parts
  alias Icyboard.Parts.Item

  @impl true
  def update(assigns, socket) do
    item = if assigns.action == :add, do: %Item{project: assigns.item.project}, else: assigns.item
    changeset = Parts.change_item item
    projects = Parts.list_projects
    epics = Parts.list_items_in_project item.project, :epic

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:item, item)
     |> assign(:epics, epics)
     |> assign(:projects, projects)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset = socket.assigns.item
    |> Parts.change_item(item_params)
    |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.action, item_params)
  end

  defp save_item(socket, :edit, item_params) do
    case Parts.update_item(socket.assigns.item, item_params, socket.assigns.user.id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Item updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_item(socket, :add, item_params) do
    case Parts.create_item(item_params, socket.assigns.user.id) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:success, "Item created successfully")
         |> push_redirect(to: Routes.item_show_path(socket, :show, item.code))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
