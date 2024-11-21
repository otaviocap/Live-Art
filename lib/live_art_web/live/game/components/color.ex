defmodule LiveArtWeb.Game.Color do
  use LiveArtWeb.BaseComponent

  attr :color, :string, required: true

  def color(assigns) do
    ~H"""
      <span phx-click="set-color" phx-value-color={@color} style={"background-color: #{@color}"}/>
    """
  end
end
