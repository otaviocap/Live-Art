defmodule LiveArtWeb.Room.NewRoomComponent do
  use LiveArtWeb, :live_component

  alias LiveArt.Game

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="room-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input
          type="password"
          field={@form[:password]}
          placeholder="Password... (keep it blank for public rooms)"
        />
        <.input
          type="number"
          field={@form[:max_players]}
          placeholder="Max players (default: 10)"
        />
        <button class="mt-4 w-full bg-blue-500 text-white py-2 rounded-lg">Create room</button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{room: room} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Game.change_room(room))
     end)}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset = Game.change_room(socket.assigns.room, room_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    case Game.create_room(room_params) do
      {:ok, room} ->
        notify_parent({:saved, room})

        {:noreply,
         socket
         |> push_navigate(to: ~p"/game/#{room.room_id}")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
