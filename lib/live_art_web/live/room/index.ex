defmodule LiveArtWeb.Room.Index do
  use LiveArtWeb, :live_view

  alias LiveArt.Game

  @impl true
  def mount(_params, _session, socket) do

    if connected?(socket), do: Game.subscribe()

    {:ok, stream(socket, :rooms, Game.list_rooms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Rooms")
    |> assign(:room, %Game.Room{})
  end

  @impl true
  def handle_info({:room_created, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  @impl true
  def handle_info({:room_updated, room}, socket) do
    {:noreply, stream_insert(socket, :rooms, room)}
  end

  @impl true
  def handle_info({:room_deleted, room}, socket) do
    {:noreply, stream_delete(socket, :rooms, room)}
  end
end
