defmodule LiveArtWeb.Game.Chat do
  use LiveArtWeb.BaseComponent

  import Core.Icon

  @doc false

  def chat(assigns) do
    ~H"""
    <div class="game-chat__container">
      <div class="text">
        <p>abc</p>
      </div>
      <div class="input">
        <input type="text" />
        <button><.icon name="hero-paper-airplane-solid" /></button>
      </div>
    </div>
    """
  end
end
