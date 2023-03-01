defmodule IcyboardWeb.ItemLive.DeleteConfirm do
  use IcyboardWeb, :live_component

  alias Icyboard.Parts

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("confirm", _, socket) do
    case Parts.delete_item(socket.assigns.item) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Item deleted successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete item")
         |> push_redirect(to: Routes.item_show_path(socket, :show, socket.assigns.item.code))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="box">
        <h2 class="mt-2 is-size-5">Delete Item?</h2>
        <p>
          Are you sure you want to delete the item "<%= @item.title %>" (<%= @item.code %>) ?
        </p>
        <button class="button is-danger" phx-click="confirm" phx-target={@myself}>
          Delete
        </button>
      </div>
    """
  end
end
