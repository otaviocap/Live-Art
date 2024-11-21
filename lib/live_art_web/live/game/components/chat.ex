defmodule LiveArtWeb.Game.Chat do
  use LiveArtWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-chat__container">
      <div class="text">
        <p :for={ message <- @stream} class={[message.from == "SYSTEM" && "system-message"]}>
          <%= if (message.from == "SYSTEM"), do: "#{message.content}", else: "#{message.from}: #{message.content}"%>
        </p>
      </div>
      <form class="input" phx-submit="submit" phx-target={@myself} id={@id} phx-change="change">
        <input type="text" name="value" value={@value} phx-debounce="300" disabled={@disabled}/>
        <button disabled={@disabled}><.icon name="hero-paper-airplane-solid" /></button>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:value, "")
    }
  end

  @impl true
  def handle_event("change", %{"value" => value}, socket) do
    {:noreply, assign(socket, :value, value)}
  end

  @impl true
  def handle_event("submit", %{"value" => value}, socket) do
    IO.inspect({:send_message, socket.assigns.id, value})
    notify_parent({:send_message, socket.assigns.id, value})

    {:noreply, assign(socket, :value, "")}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
