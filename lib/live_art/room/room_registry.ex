defmodule LiveArt.Room.RoomRegistry do
  def child_spec do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__,
      partitions: System.schedulers_online()
    )
  end

  def lookup_room(room_id) do
    case Registry.lookup(__MODULE__, room_id) do
      [{room_pid, _}] -> {:ok, room_pid}
      [] -> {:error, :not_found}
    end
  end
end
