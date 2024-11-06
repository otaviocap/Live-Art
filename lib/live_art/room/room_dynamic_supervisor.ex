defmodule LiveArt.Room.RoomDynamicSupervisor do
  use DynamicSupervisor
  alias LiveArt.Room.RoomRegistry
  alias LiveArt.Game.Room
  alias LiveArt.Room.RoomProcess

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def create_room(%Room{} = room) do
    child_spec = %{
      id: RoomProcess,
      start: {RoomProcess, :start_link, [room]},
      restart: :transient
    }

    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def delete_room(%Room{} = room) do
    case RoomRegistry.lookup_room(room.room_id) do
      {:ok, pid} ->  DynamicSupervisor.terminate_child(__MODULE__, pid)
      {:error, _error} = error -> error
    end
  end

  def all_rooms_pids do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.reduce([], fn {_, room_pid, _, _}, acc ->
      [room_pid | acc]
    end)
  end
end
