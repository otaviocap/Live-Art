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
    case Game.get_room_by_id(id) do
      %LiveArt.Game.Room{} = room ->
        {:noreply,
         socket
         |> should_guard(
           id,
           not Map.has_key?(socket.assigns, :user) and socket.assigns.live_action in [:index]
         )
         |> assign(:page_title, "Game")
         |> assign(:room, room)}

      nil ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/")
        }
    end
  end

  @impl true
  def handle_info({LiveArtWeb.Game.RoomGuard, {:login_successful, name}}, socket) do
    IO.inspect("test")

    socket =
      socket
      |> assign(:user, name)
      |> push_patch(to: ~p"/game/#{socket.assigns.room.room_id}")
      |> put_flash(:info, "Login successful")

    {:noreply, socket}
  end

  defp should_guard(socket, id, true) do
    push_patch(socket, to: ~p"/game/#{id}/enter")
  end

  defp should_guard(socket, _id, false) do
    socket
  end
end
