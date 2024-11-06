defmodule LiveArt.Room.RoomReactiveHandler do
  use GenServer

  require Logger

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    LiveArt.Game.subscribe()

    Logger.info("Room reactive handler connected!")

    {:ok, state}
  end

  @impl true
  def handle_info({:room_created, room}, state) do
    Logger.info("Creating room #{room.room_id} process")

    LiveArt.Room.RoomDynamicSupervisor.create_room(room)

    {:noreply, state}
  end

  @impl true
  def handle_info({:room_deleted, room}, state) do
    Logger.info("Deleting room #{room.room_id} process")

    LiveArt.Room.RoomDynamicSupervisor.delete_room(room)

    {:noreply, state}
  end
end
