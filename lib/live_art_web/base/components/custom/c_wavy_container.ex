defmodule LiveArtWeb.Custom.CWavyContainer do
  use LiveArtWeb.BaseComponent

  import Core.Icon

  @doc """
  Renders the wavy container.

  ## Examples
    <.c_wavy_container>
      This is inside the container
    </.c_wavy_container>
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true
  slot :title, required: false
  slot :small_text, required: false

  def c_wavy_container(assigns) do
    ~H"""
    <div class={["c-wavy-container__container", @class]}>
      <div class="top">
        <div class="content">
          <div class="logo">
            <.icon name="hero-paint-brush-solid" />
            <%= if Enum.any?(@title) do %>
              <%= render_slot(@title) %>
            <% else %>
              <p>Live<span class="subtitle">art</span></p>
            <% end %>
          </div>
          <%= if Enum.any?(@small_text) do %>
              <%= render_slot(@small_text) %>
            <% else %>
              <p class="small_text">v1.0</p>
            <% end %>
        </div>
      </div>
      <div class="content">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
