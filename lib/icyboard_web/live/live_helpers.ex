defmodule IcyboardWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.overview_index_path(@socket, :index)}>
        <.live_component
          module={IcyboardWeb.ProjectLive.FormComponent}
          id={@overview.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.overview_index_path(@socket, :index)}
          overview: @overview
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="modal is-active" phx-remove={hide_modal()}>
      <div class="modal-background"></div>
      <div
        id="modal-content"
        class="modal-content"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape">
        <%= render_slot(@inner_block) %>
      </div>
      <%= if @return_to do %>
        <%= live_patch "✖",
          to: @return_to,
          id: "close",
          class: "modal-close",
          phx_click: hide_modal()
        %>
      <% else %>
        <button id="modal-close" class="modal-close is-large" aria-label="close" phx-click={hide_modal()}>✖</button>
      <% end %>
    </div>
    """
  end

  def pretty_item_type(assigns) do
    assigns = assign_new(assigns, :value, fn -> nil end)
    text = case assigns.value do
      :epic -> "Epic"
      :story -> "Story"
      :task -> "Task"
      :bug -> "Bug"
      :subtask -> "Sub-task"
      _ -> "Unknown"
    end

    ~H"""
      <.type_badge value={assigns.value} />
      <%= text %>
    """
  end

  def pretty_item_priority(assigns) do
    assigns = assign_new(assigns, :value, fn -> nil end)
    text = case assigns.value do
      :low -> "Low"
      :normal -> "Normal"
      :high -> "High"
      :urgent -> "Urgent"
      _ -> "Unknown"
    end

    ~H"""
      <.priority_badge value={assigns.value} />
      <%= text %>
    """
  end

  def type_badge(assigns) do
    assigns = assign_new(assigns, :value, fn -> nil end)

    case assigns.value do
      :epic ->
        ~H"""
          <span class="item-type epic">
            <i class="fa-solid fa-bolt-lightning"></i>
          </span>
        """

      :story ->
        ~H"""
          <span class="item-type story">
            <i class="fa-solid fa-bookmark"></i>
          </span>
        """

      :task ->
        ~H"""
          <span class="item-type task">
            <i class="fa-solid fa-check"></i>
          </span>
        """

      :bug ->
        ~H"""
          <span class="item-type bug">
            <i class="fa-solid fa-circle"></i>
          </span>
        """

      :subtask ->
        ~H"""
          <span class="item-type subtask">
            <i class="fa-solid fa-diagram-project"></i>
          </span>
        """

      _ ->
        ~H"""
          <span class="item-type unknown">
            <i class="fa-solid fa-question"></i>
          </span>
        """
    end
  end

  def priority_badge(assigns) do
    assigns = assign_new(assigns, :value, fn -> nil end)

    case assigns.value do
      :low ->
        ~H"""
          <span class="item-priority low">
            <i class="fa-solid fa-chevron-down"></i>
          </span>
        """

      :normal ->
        ~H"""
          <span class="item-priority normal">
            <i class="fa-solid fa-equals"></i>
          </span>
        """

      :high ->
        ~H"""
          <span class="item-priority high">
            <i class="fa-solid fa-chevron-up"></i>
          </span>
        """

      :urgent ->
        ~H"""
          <span class="item-priority urgent">
            <i class="fa-solid fa-angles-up"></i>
          </span>
        """

      _ ->
        ~H"""
          <span class="item-priority unknown">
            <i class="fa-solid fa-question"></i>
          </span>
        """
    end
  end

  def state_badge(assigns) do
    assigns = assign_new(assigns, :value, fn -> nil end)

    case assigns.value do
      :todo ->
        ~H"""
          <span class="item-state has-background-grey">TO DO</span>
        """

      :active ->
        ~H"""
          <span class="item-state has-background-info">IN PROGRESS</span>
        """

      :done ->
        ~H"""
          <span class="item-state has-background-success">DONE</span>
        """

      _ ->
        ~H"""
          <span class="item-state has-background-grey-lighter has-text-dark">UNKNOWN</span>
        """
    end
  end

  def dropdown_menu(assigns) do
    assigns = assign_new(assigns, :icon, fn -> nil end)
    assigns = assign_new(assigns, :text, fn -> nil end)

    ~H"""
    <div class="dropdown" id={"#{@id}-dropdown"} phx-click-away={hide_dropdown_menu(@id)}>
        <div class="dropdown-trigger">
            <button
              class="button is-light"
              phx-click={toggle_dropdown_menu(@id)}
              aria-haspopup="true"
              aria-controls={@id}>
                <%= if @icon do %>
                  <span class="icon is-small">
                      <i class={"fa-solid fa-#{@icon}"}></i>
                  </span>
                <% end %>
                <%= if @text do %>
                  <span>
                    <%= @text %>
                  </span>
                <% end %>
            </button>
        </div>
        <div class="dropdown-menu" id={@id} role="menu">
            <div class="dropdown-content">
                <%= render_slot(@inner_block) %>
            </div>
        </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  defp toggle_dropdown_menu(id, js \\ %JS{}) do
    js
    |> JS.dispatch("icyboard_ui:toggle_active", to: "##{id}-dropdown")
  end

  defp hide_dropdown_menu(id, js \\ %JS{}) do
    js
    |> JS.dispatch("icyboard_ui:remove_active", to: "##{id}-dropdown")
  end
end
