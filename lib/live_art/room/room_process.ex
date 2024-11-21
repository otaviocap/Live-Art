defmodule LiveArt.Room.RoomProcess do
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

    Logger.info("Adding player #{player_name} to #{state.room.room_id}")

    {:reply, state, state}
  end

  @impl true
  def handle_call({:remove_player, player_name}, _from, %RunningRoom{} = state) do
    state = RunningRoom.remove_player(state, player_name)

    LiveArt.Game.remove_player(state.room.room_id)

    broadcast(state.room.room_id, :state_updated, state)

    Logger.info("Removing player #{player_name} to #{state.room.room_id}")

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
  def handle_info(:check_start_game, %RunningRoom{} = state) do
    Logger.info("Game isnt started, waiting for 2 players")

    if (length(state.players) >= 2) do
      Process.send(self(), :pause_game, [])
    else
      Process.send_after(self(), :check_start_game, 2000)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:pause_game, %RunningRoom{} = state) do

    Logger.info("Game is paused, waiting for 2 players")

    if (length(state.players) >= 2) do
      Process.send_after(self(), :start_game, 5000)
    else
      Process.send_after(self(), :pause_game, 2000)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:start_game, %RunningRoom{} = state) do
    state = RunningRoom.start_game(state, LiveArt.Words.get_random_word())

    broadcast(state.room.room_id, :state_updated, state)

    Logger.info("Starting game, artist: #{inspect state.current_player_drawing} word #{state.current_word}. Id: #{state.room.room_id}")

    Process.send_after(self(), :end_round, 30000)

    {:noreply, state}
  end

  @impl true
  def handle_info(:end_round, %RunningRoom{} = state) do
    state = RunningRoom.end_round(state)

    broadcast(state.room.room_id, :state_updated, state)

    Logger.info("Endend round. Id: #{state.room.room_id}")

    if (RunningRoom.has_winner(state)) do
      Process.send_after(self(), :end_game, 5000)
    else
      Process.send_after(self(), :start_game, 5000)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:end_game, %RunningRoom{} = state) do
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
