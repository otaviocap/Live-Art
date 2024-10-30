defmodule LiveArtWeb.Game.Index do
  use LiveArtWeb, :live_view

  alias LiveArt.Game

  import LiveArtWeb.Game.Player

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"room_id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Game")
     |> assign(:room, Game.get_room_by_id!(id))}
  end
end
