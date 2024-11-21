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
         |> assign_room_state(room)
         |> should_guard(
           id,
           not Map.has_key?(socket.assigns, :user) and socket.assigns.live_action in [:index]
         )
         |> assign(:page_title, "Game")
         |> assign(:room, room)
         |> subscribe_to_events()}

      nil ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/")}
    end
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

    {:noreply, socket}
  end

  @impl true
  def handle_info({LiveArtWeb.Game.Chat, {:send_message, :answer, value}}, socket) do
    is_correct = String.upcase(value) == String.upcase(socket.assigns.room_state.current_word)

    if (is_correct) do
      RoomProcess.add_score(socket.assigns.room_pid, socket.assigns.user, 10)

      RoomChat.send_chat(
        socket.assigns.room.room_id,
        :answer,
        %{from: "SYSTEM", content: "#{socket.assigns.user} acertou a palavra"}
      )

      {:noreply, assign(socket, :block_answers, true)}
    else
      RoomChat.send_chat(
        socket.assigns.room.room_id,
        :answer,
        %{from: socket.assigns.user, content: value}
        )

      IO.inspect("Should be unblocking")
        {:noreply, socket}
    end

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
    {:noreply, assign(socket, :room_state, state)}
  end

  @impl true
  def handle_info({:round_started, state}, socket) do
    if state.current_player_drawing != "" &&
         Map.has_key?(socket.assigns, :user) &&
         state.current_player_drawing == socket.assigns.user
    do
      {:noreply,
       socket
       |> assign(:am_i_the_artist, true)
       |> assign(:block_answers, true)
       |> assign(:room_state, state)
       |> push_event("enable_drawing", %{})}
    else
      {:noreply,
       socket
       |> assign(:am_i_the_artist, false)
       |> assign(:block_answers, false)
       |> assign(:room_state, state)
       |> push_event("disable_drawing", %{})}
    end
  end

  @impl true
  def handle_info({:round_ended, state}, socket) do
      {:noreply,
       socket
       |> assign(:am_i_the_artist, false)
       |> assign(:block_answers, true)
       |> assign(:room_state, state)
       |> push_event("disable_drawing", %{})}
  end

  @impl true
  def handle_info({:clear_drawing, state}, socket) do
    socket = assign(socket, :room_state, state)

    {:noreply, push_event(socket, "clear_canvas", %{})}
  end

  @impl true
  def handle_info({:undo_stroke, state}, socket) do
    socket = assign(socket, :room_state, state)

    {:noreply, push_event(socket, "undo", %{})}
  end

  @impl true
  def handle_info({:add_drawing_stroke, state}, socket) do
    socket = assign(socket, :room_state, state)

    {:noreply, push_event(socket, "add_stroke", hd(state.current_drawing))}
  end

  @impl true
  def handle_event("set-color", %{"color" => color}, socket) do
    {:noreply, push_event(socket, "change_color", %{color: color})}
  end

  @impl true
  def handle_event("clear-canvas", _values, socket) do
    RoomProcess.clear_drawing(socket.assigns.room_pid)

    {:noreply, push_event(socket, "clear_canvas", %{})}
  end

  @impl true
  def handle_event("undo", _values, socket) do
    RoomProcess.undo_stroke(socket.assigns.room_pid)

    {:noreply, push_event(socket, "undo", %{})}
  end

  @impl true
  def handle_event("canvas-update", stroke, socket) do
    RoomProcess.add_drawing_stroke(socket.assigns.room_pid, stroke)

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
        socket
        |> assign(:room_pid, room_pid)
        |> assign(:chat_stream, [])
        |> assign(:answer_stream, [])
        |> assign(:room_state, RoomProcess.get_state(room_pid))
        |> assign(:am_i_the_artist, false)
        |> assign(:block_answers, true)

      {:error, _error} ->
        socket
        |> put_flash(:error, "Could not get room state")
    end
  end

  defp subscribe_to_events(socket) do
    if !Map.has_key?(socket.assigns, :subscribed) do
      room_id = socket.assigns.room.room_id

      RoomProcess.subscribe(room_id)
      RoomChat.subscribe(room_id, :chat)
      RoomChat.subscribe(room_id, :answer)
    end

    socket
    |> assign(:subscribed, true)
  end
end
