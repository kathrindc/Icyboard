defmodule IcyboardWeb.ProjectLive.Show do
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
    project = Parts.get_project!(code)
    items = Parts.list_items_in_project(code, :any)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:project, project)
     |> assign(:items, items)}
  end

  defp page_title(:show), do: "Show Project"
  defp page_title(:add), do: "Add Item"
end
