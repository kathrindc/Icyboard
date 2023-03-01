defmodule IcyboardWeb.ItemLive.CloneForm do
  use IcyboardWeb, :live_component

  alias Icyboard.Parts
  alias Icyboard.Parts.Item

  @impl true
  def update(%{original: original} = assigns, socket) do
    item = %Item{title: "CLONE - #{original.title}"}
    changeset = Item.title_changeset item, %{}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:item, item)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset = socket.assigns.item
    |> Item.title_changeset item_params
    |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"item" => item_params}, socket) do
    case Parts.clone_item(socket.assigns.original, item_params, socket.assigns.user.id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Item cloned successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
