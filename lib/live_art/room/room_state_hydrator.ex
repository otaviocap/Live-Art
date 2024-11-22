defmodule LiveArt.Room.RoomStateHydrator do
  use GenServer, restart: :transient

  require Logger

  alias LiveArt.Game.Room
  alias LiveArt.Room.RoomDynamicSupervisor

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__, timeout: 10_000)
  end

  @impl true
  def init(_) do
    Logger.info("#{inspect(Time.utc_now())} Starting room process hydration")

    LiveArt.Game.clear_all_players()

    LiveArt.Game.list_rooms()
    |> Enum.each(fn %Room{} = room -> RoomDynamicSupervisor.create_room(room) end)

    Logger.info("#{inspect(Time.utc_now())} Completed room process hydration")

    :ignore
  end
end
