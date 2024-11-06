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

end
