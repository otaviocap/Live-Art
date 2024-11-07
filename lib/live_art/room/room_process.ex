defmodule LiveArt.Room.RoomProcess do
  alias LiveArt.Room.RunningRoom
  alias LiveArt.Room.RoomRegistry
  alias LiveArt.Game.Room
  use GenServer, restart: :transient

  require Logger

  def start_link(%Room{} = room) do
    GenServer.start_link(__MODULE__, room,
      name: {:via, Registry, {RoomRegistry, room.room_id}}
    )
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

  @impl true
  def init(%Room{} = base_state) do
    state = %RunningRoom{
      room: base_state
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:read, _from, %RunningRoom{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:add_player, player_name}, _from, %RunningRoom{} = state) do
    state = RunningRoom.add_player(state, player_name)
    broadcast(state.room.room_id, :state_updated, state)

    Logger.info("Adding player #{player_name} to #{state.room.room_id}")

    {:reply, state, state}
  end

  @impl true
  def handle_call({:remove_player, player_name}, _from, %RunningRoom{} = state) do
    state = RunningRoom.remove_player(state, player_name)
    broadcast(state.room.room_id, :state_updated, state)

    Logger.info("Removing player #{player_name} to #{state.room.room_id}")

    {:reply, state, state}
  end


  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(LiveArt.PubSub, "room_events:#{room_id}")
  end

  defp broadcast(room_id, event, data) do
    Phoenix.PubSub.broadcast(LiveArt.PubSub, "room_events:#{room_id}", {event, data})
  end


end
