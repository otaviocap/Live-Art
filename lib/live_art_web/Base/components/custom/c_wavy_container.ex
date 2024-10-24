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
  slot :inner_block, required: true

  def c_wavy_container(assigns) do
    ~H"""
    <div class="c-wavy-container__container">
      <div class="top">
        <div class="content">
          <div class="logo">
            <.icon name="hero-paint-brush-solid" />
            <p>Live<span class="subtitle">art</span></p>
          </div>
          <p class="version">v1.0</p>
        </div>
      </div>
      <div class="content">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
