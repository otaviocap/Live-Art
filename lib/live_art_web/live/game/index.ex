defmodule LiveArtWeb.Game.Index do
  use LiveArtWeb, :live_view

  alias LiveArt.Game

  import LiveArtWeb.Game.Player
  import LiveArtWeb.Game.Canvas
  import LiveArtWeb.Game.Chat

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"room_id" => id}, _, socket) do
    {:noreply,
     socket
     |> should_guard(
       id,
       not Map.has_key?(socket.assigns, :user) and socket.assigns.live_action in [:index]
     )
     |> assign(:page_title, "Game")
     |> assign(:room, Game.get_room_by_id!(id))}
  end

  defp should_guard(socket, id, true) do
    IO.inspect("guarding")
    socket = push_patch(socket, to: ~p"/game/#{id}/enter")

    socket
  end

  defp should_guard(socket, _id, false) do
    IO.inspect("letting")
    IO.inspect(socket.assigns)
    socket
  end
end
