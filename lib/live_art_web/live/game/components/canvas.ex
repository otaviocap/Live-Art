defmodule LiveArtWeb.Game.Canvas do
  use LiveArtWeb.BaseComponent

  import Core.Icon
  import LiveArtWeb.Game.Color


  @doc false

  def canvas(assigns) do
    ~H"""
    <div class="game-canvas__container">
      <div class="word">praia</div>
      <div class="main">
        <div class="tools">
          <.color color="#000000"/>
          <.color color="#FF0000"/>
          <.color color="#FF8800"/>
          <.color color="#FFF700"/>
          <.color color="#00FF0D"/>
          <.color color="#1900FF"/>
          <.color color="#E100FF"/>
          <.color color="#FF0062"/>
          <span id="color-picker"/>
          <span class="icon" phx-click="clear-canvas"><.icon name="hero-trash-solid" /></span>
          <span class="icon" phx-click="undo"><.icon name="hero-backward-solid" /></span>
        </div>
        <div class="drawing">
          <svg id="svgCanvas" phx-hook="CanvasHook">
          </svg>
        </div>
      </div>
    </div>
    """
  end
end
