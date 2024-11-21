defmodule LiveArtWeb.Game.RoomGuard do
  alias LiveArt.Room.RoomProcess

  use LiveArtWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="room-guard">
      <span class="shadow"></span>
      <.c_wavy_container class="s-size modal">
        <:small_text>
          <p class="small-text">#<%= @room.room_id %></p>
        </:small_text>
        <.form
          for={@form}
          id="room-guard-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input type="text" field={@form[:name]} placeholder="Name" />
          <.input
            type="password"
            field={@form[:password]}
            placeholder="Password... (keep it blank for public rooms)"
          />
          <button class="mt-4 w-full bg-blue-500 text-white py-2 rounded-lg">Play</button>
        </.form>
        <p class="error"><%= @error %></p>
      </.c_wavy_container>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    form_fields = %{"name" => "", "password" => ""}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:error, "")
     |> assign_new(:form, fn -> to_form(form_fields) end)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, assign(socket, form: socket.assigns.form)}
  end

  def handle_event("save", %{"name" => name, "password" => password}, socket) do
    case validate_name(socket, name) and validate_password(socket, password) do
      true ->
        notify_parent({:login_successful, name})

        {:noreply,
         socket
         |> assign(:user, name)
         |> push_patch(to: ~p"/game/#{socket.assigns.room.room_id}", replace: true)}

      false ->
        {:noreply,
         socket
         |> assign(:error, "Incorrect password or name already in use")}
    end
  end

  defp validate_name(socket, name) do
    name != ""
    #&& name != "SYSTEM"
    && RoomProcess.validate_name(socket.assigns.room_pid, name)
  end

  defp validate_password(socket, password) do
    socket.assigns.room.password == password
    or socket.assigns.room.password == ""
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
