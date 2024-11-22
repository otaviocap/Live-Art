defmodule LiveArt.Room.RoomProcess do
  alias LiveArt.Room.RoomDynamicSupervisor
  alias LiveArt.Room.RoomChat
  alias LiveArt.Room.RunningRoom
  alias LiveArt.Room.RoomRegistry
  alias LiveArt.Game.Room
  use GenServer, restart: :transient

  require Logger

  def start_link(%Room{} = room) do
    GenServer.start_link(__MODULE__, room, name: {:via, Registry, {RoomRegistry, room.room_id}})
  end

  def get_state(room_pid) when is_pid(room_pid) do
    GenServer.call(room_pid, :read)
  end

  def add_player(room_pid, player_name) when is_pid(room_pid) do
    GenServer.call(room_pid, {:add_player, player_name})
  end

  def remove_player(room_pid, player_name) when is_pid(room_pid) do
    GenServer.call(room_pid, {:remove_player, player_name})
  end

  def add_drawing_stroke(room_pid, drawing_stroke) when is_pid(room_pid) do
    GenServer.call(room_pid, {:add_drawing_stroke, drawing_stroke})
  end

  def undo_stroke(room_pid) when is_pid(room_pid) do
    GenServer.call(room_pid, :undo_stroke)
  end

  def clear_drawing(room_pid) when is_pid(room_pid) do
    GenServer.call(room_pid, :clear_drawing)
  end

  def validate_name(room_pid, name) when is_pid(room_pid) do
    GenServer.call(room_pid, {:validate_name, name})
  end

  def add_score(room_pid, name, score) when is_pid(room_pid) do
    GenServer.call(room_pid, {:add_score, name, score})
  end

  @impl true
  def init(%Room{} = base_state) do
    state = %RunningRoom{
      room: base_state
    }

    Process.send_after(self(), :check_start_game, 2000)

    {:ok, state}
  end

  @impl true
  def handle_call(:read, _from, %RunningRoom{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:validate_name, player_name}, _from, %RunningRoom{} = state) do
    has_player = Enum.count(state.players, fn e -> e.name == player_name end) > 0

    {:reply, !has_player, state}
  end

  @impl true
  def handle_call({:add_player, player_name}, _from, %RunningRoom{} = state) do
    state = RunningRoom.add_player(state, player_name)

    LiveArt.Game.add_player(state.room.room_id)

    broadcast(state.room.room_id, :state_updated, state)

    RoomChat.send_chat(state.room.room_id, :answer, %{
      from: "SYSTEM",
      content: "#{player_name} entrou na sala"
    })

    {:reply, state, state}
  end

  @impl true
  def handle_call({:remove_player, player_name}, _from, %RunningRoom{} = state) do
    state = RunningRoom.remove_player(state, player_name)

    LiveArt.Game.remove_player(state.room.room_id)

    broadcast(state.room.room_id, :state_updated, state)

    RoomChat.send_chat(state.room.room_id, :answer, %{
      from: "SYSTEM",
      content: "#{player_name} saiu da sala"
    })

    if length(state.players) == 0 do
      Process.send(self(), :start_end_clock, [])
    end

    {:reply, state, state}
  end

  @impl true
  def handle_call({:add_drawing_stroke, drawing_stroke}, _from, %RunningRoom{} = state) do
    state = RunningRoom.add_drawing_stroke(state, drawing_stroke)

    broadcast(state.room.room_id, :add_drawing_stroke, state)

    {:reply, state, state}
  end

  @impl true
  def handle_call(:undo_stroke, _from, %RunningRoom{} = state) do
    state = RunningRoom.undo_drawing_stroke(state)

    broadcast(state.room.room_id, :undo_stroke, state)

    {:reply, state, state}
  end

  @impl true
  def handle_call(:clear_drawing, _from, %RunningRoom{} = state) do
    state = RunningRoom.clear_drawing(state)

    broadcast(state.room.room_id, :clear_drawing, state)

    {:reply, state, state}
  end

  @impl true
  def handle_call({:add_score, name, score}, _from, %RunningRoom{} = state) do
    state = RunningRoom.add_score(state, name, score)
    state = RunningRoom.add_score(state, state.current_player_drawing, score/2)

    broadcast(state.room.room_id, :state_updated, state)

    {:reply, state, state}
  end

  @impl true
  def handle_info(:start_end_clock, %RunningRoom{} = state) do
    if state.end_clock != nil do
      Process.cancel_timer(state.end_clock)
    end

    if length(state.players) == 0 do
      {:noreply,
       RunningRoom.set_end_clock(state, Process.send_after(self(), :run_end_clock, 20000))}
    else
      {:noreply, state}
    end

  end

  @impl true
  def handle_info(:run_end_clock, %RunningRoom{} = state) do
    if length(state.players) == 0 do
      LiveArt.Game.delete_room(state.room)
      RoomDynamicSupervisor.delete_room(state.room)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:check_start_game, %RunningRoom{} = state) do
    if length(state.players) >= 2 do
      Logger.info("Game (#{state.room.room_id}) will start")
      Process.send(self(), :pause_game, [])
    else
      Process.send_after(self(), :check_start_game, 2000)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:pause_game, %RunningRoom{} = state) do
    if length(state.players) >= 2 do
      Process.send_after(self(), :start_game, 5000)
    else
      Process.send_after(self(), :pause_game, 2000)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:start_game, %RunningRoom{} = state) do
    state = RunningRoom.start_game(state, LiveArt.Words.get_random_word())

    broadcast(state.room.room_id, :round_started, state)

    RoomChat.send_chat(state.room.room_id, :answer, %{
      from: "SYSTEM",
      content: "#{state.current_player_drawing} é o(a) artista da rodada"
    })

    Logger.info(
      "Starting game, artist: #{state.current_player_drawing} word #{state.current_word}. Id: #{state.room.room_id}"
    )

    Process.send_after(self(), :end_round, 30000)

    {:noreply, state}
  end

  @impl true
  def handle_info(:end_round, %RunningRoom{} = state) do
    RoomChat.send_chat(state.room.room_id, :answer, %{
      from: "SYSTEM",
      content: "Acabou rodada. A palavra era: #{state.current_word}"
    })

    state = RunningRoom.end_round(state)

    broadcast(state.room.room_id, :round_ended, state)

    if RunningRoom.has_winner(state) do
      Process.send_after(self(), :end_game, 5000)
    else
      Process.send_after(self(), :pause_game, 5000)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:end_game, %RunningRoom{} = state) do
    winners = Enum.sort(state.players, &(&1.score > &2.score))

    RoomChat.send_chat(state.room.room_id, :answer, %{from: "SYSTEM", content: "Acabou o jogo:"})

    RoomChat.send_chat(state.room.room_id, :answer, %{
      from: "SYSTEM",
      content: "1°: #{Enum.at(winners, 0).name} (#{Enum.at(winners, 0).score})"
    })

    RoomChat.send_chat(state.room.room_id, :answer, %{
      from: "SYSTEM",
      content: "2°: #{Enum.at(winners, 1).name} (#{Enum.at(winners, 1).score})"
    })

    if length(winners) > 2 do
      RoomChat.send_chat(state.room.room_id, :answer, %{
        from: "SYSTEM",
        content: "3°: #{Enum.at(winners, 2).name} (#{Enum.at(winners, 2).score})"
      })
    end

    state = RunningRoom.end_game(state)

    broadcast(state.room.room_id, :state_updated, state)

    Logger.info("Endend game. Id: #{state.room.room_id}")

    Process.send_after(self(), :check_start_game, 5000)

    {:noreply, state}
  end

  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(LiveArt.PubSub, "room_events:#{room_id}")
  end

  defp broadcast(room_id, event, data) do
    Phoenix.PubSub.broadcast(LiveArt.PubSub, "room_events:#{room_id}", {event, data})
  end
end
