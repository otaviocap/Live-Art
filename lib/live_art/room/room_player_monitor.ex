defmodule LiveArt.Room.RoomPlayerMonitor do
  alias LiveArt.Room.RoomProcess
  use GenServer

  def monitor(socket_id, room_pid, player_name) do
    pid = GenServer.whereis({:global, __MODULE__})

    GenServer.call(pid, {:monitor, {socket_id, room_pid, player_name}})
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: {:global, __MODULE__})
  end

  @impl true
  def init(_opts) do
    state = %{views: %{}}

    {:ok, state}
  end

  @impl true
  def handle_call(
        {:monitor, {socket_id, room_pid, player_name}},
        {view_pid, _ref},
        %{views: views} = state
      ) do
    mref = Process.monitor(view_pid)
    new_state = %{state | views: Map.put(views, view_pid, {mref, socket_id, room_pid, player_name})}

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, view_pid, _reason}, state) do
    {{_mref, _socket_id, room_pid, player_name}, remaining_views} = Map.pop(state.views, view_pid)

    RoomProcess.remove_player(room_pid, player_name)

    new_state = %{state | views: remaining_views}
    {:noreply, new_state}
  end
end
