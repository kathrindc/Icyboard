defmodule IcyboardWeb.ProjectLive.New do
  use IcyboardWeb, :live_view

  alias Icyboard.Parts
  alias Icyboard.Parts.Project

  @impl true
  def mount(_params, _session, socket) do
    project = %Project{}
    changeset = Parts.change_project(project)
    socket = socket
    |> assign(:project, project)
    |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = socket.assigns.project
    |> Parts.change_project(project_params)
    |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"project" => project_params}, socket) do
    case Parts.create_project(project_params) do
      {:ok, story} ->
        {:noreply,
         socket
         |> put_flash(:success, "Project created successfully")
         |> push_redirect(to: Routes.project_show_path(socket, :show, story.code))}
    end
  end
end
