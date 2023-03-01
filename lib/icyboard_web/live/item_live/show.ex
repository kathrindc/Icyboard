defmodule IcyboardWeb.ItemLive.Show do
  use IcyboardWeb, :live_view

  alias Icyboard.Parts
  alias Icyboard.Accounts

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    {:ok,
     socket
     |> assign(:user, user)}
  end

  @impl true
  def handle_params(%{"code" => code}, _, socket) do
    item = Parts.get_item! code
    parent = Parts.get_item item.parent
    epic = Parts.get_item item.epic
    project = Parts.get_project! item.project
    subitems = if item.type == :epic,
      do: (Parts.list_items_in_epic code, :any),
      else: (Parts.list_items_in_parent code, :any)
    reporter = if item.reported_by, do: (Accounts.get_user! item.reported_by), else: nil
    updater = if item.updated_by, do: (Accounts.get_user! item.updated_by), else: nil

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, item)
     |> assign(:parent, parent)
     |> assign(:epic, epic)
     |> assign(:project, project)
     |> assign(:subitems, subitems)
     |> assign(:reporter, reporter)
     |> assign(:updater, updater)}
  end

  @impl true
  def handle_event("change_state", %{"value" => value}, socket) do
    case Parts.apply_item_state(socket.assigns.item, value, socket.assigns.user.id) do
      {:ok, item} ->
        {:noreply, assign(socket, item: item)}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Unable to update item state.")}
    end
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:add), do: "Add Item"
  defp page_title(:edit), do: "Edit Item"
  defp page_title(:clone), do: "Clone Item"
  defp page_title(:delete), do: "Delete Item"
end
