defmodule LiveArtWeb.Game.Player do
  use LiveArtWeb.BaseComponent

  @doc false
  attr :name, :string, required: true
  attr :score, :integer, required: true
  attr :id, :string, required: true

  def player(assigns) do
    ~H"""
    <div class="game-player__container" id={@id}>
      <div class="info">
        <img src={"https://robohash.org/set_set4/bgset_bg2/#{@name}?size=100x100"} class="avatar" />
        <p class="name"><%= @name %></p>
      </div>
      <p class="score"><%= @score %></p>
    </div>
    """
  end
end
