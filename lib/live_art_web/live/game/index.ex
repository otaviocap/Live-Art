defmodule LiveArtWeb.Game.Index do
  alias LiveArt.Room.RoomChat
  alias LiveArt.Room.RoomPlayerMonitor
  alias LiveArt.Room.RoomProcess
  use LiveArtWeb, :live_view

  alias LiveArt.Game

  import LiveArtWeb.Game.Player
  import LiveArtWeb.Game.Canvas

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
         |> assign(:room, room)
         |> assign_room_state(room)}

      nil ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/")}
    end
  end

  @impl true
  def handle_info({LiveArtWeb.Game.Chat, {:send_message, :answer, value}}, socket) do
    socket =
      socket
      |> put_flash(:info, "From answer: #{value}")

    {:noreply, socket}
  end

  @impl true
  def handle_info({LiveArtWeb.Game.Chat, {:send_message, :chat, value}}, socket) do
    RoomChat.send_chat(
      socket.assigns.room.room_id,
      :chat,
      %{from: socket.assigns.user, content: value}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:state_updated, state}, socket) do
    socket = assign(socket, :room_state, state)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_chat, category, message}, socket) do
    send_update(LiveArtWeb.Game.Chat, id: :chat)

    stream = if category == :answer, do: :answer_stream, else: :chat_stream

    IO.inspect("Updating stream with new chat")

    {:noreply, assign(socket, stream, [message | socket.assigns[stream]])}
  end

  @impl true
  def handle_info({LiveArtWeb.Game.RoomGuard, {:login_successful, name}}, socket) do
    name = String.slice(name, 0..15)

    RoomProcess.add_player(socket.assigns.room_pid, name)

    if connected?(socket), do: RoomPlayerMonitor.monitor(socket.id, socket.assigns.room_pid, name)

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

  defp assign_room_state(socket, room) do
    case LiveArt.Room.RoomRegistry.lookup_room(room.room_id) do
      {:ok, room_pid} ->

        if (!Map.has_key?(socket.assigns, :subscribed)) do
          RoomProcess.subscribe(room.room_id)
          RoomChat.subscribe(room.room_id, :chat)
          RoomChat.subscribe(room.room_id, :answer)
        end


        socket
        |> assign(:room_pid, room_pid)
        |> assign(:chat_stream, [])
        |> assign(:answer_stream, [])
        |> assign(:subscribed, true)
        |> assign(:room_state, RoomProcess.get_state(room_pid))

      {:error, _error} ->
        socket
        |> put_flash(:error, "Could not get room state")
    end
  end
end
