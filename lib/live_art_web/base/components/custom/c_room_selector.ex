defmodule LiveArtWeb.Custom.CRoomSelector do
  use LiveArtWeb.BaseComponent

  import Core.Icon

  @doc """
  Renders the wavy container.

  ## Examples
    <.wavy_container>
      This is inside the container
    </.wavy_container>
  """
  attr :room_id, :string, required: true
  attr :max_players, :integer, required: true
  attr :current_players, :integer, required: true
  attr :has_password, :boolean, required: true
  attr :id, :string, required: true
  attr :click, :any, default: nil, doc: "the function for handling phx-click on each selector"

  def c_room_selector(assigns) do
    ~H"""
    <div
      class="c-room-selector__container hover:bg-blue-200 transition duration-300"
      id={@id}
      phx-click={@click}
    >
      <div class="content">
        <div class="details">
          <.icon :if={@has_password} name="hero-lock-closed-solid" />
          <p class="room-id">#<%= @room_id %></p>
          <span> - </span>
          <p><%= @current_players %> / <%= @max_players %> players</p>
        </div>

        <.icon name="hero-arrow-right-start-on-rectangle-solid" />
      </div>

      <hr />
    </div>
    """
  end
end
