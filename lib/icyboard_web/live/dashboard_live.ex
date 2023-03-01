defmodule IcyboardWeb.DashboardLive do
  use IcyboardWeb, :live_view

  alias Icyboard.Projects
  alias Icyboard.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <h1 class="mt-2 is-size-3">Dashboard</h1>
    """
  end
end
