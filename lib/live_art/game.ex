defmodule LiveArt.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias LiveArt.Repo

  alias LiveArt.Game.Room

  def list_rooms do
    Repo.all(Room)
  end

  def get_room_by_id(id), do: Repo.get_by(Room, room_id: id)

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:room_created)
  end

  def delete_room(%Room{} = room) do
    Repo.delete(room)
    |> broadcast(:room_deleted)
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(LiveArt.PubSub, "liveart_rooms")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, room}, event) do
    Phoenix.PubSub.broadcast(LiveArt.PubSub, "liveart_rooms", {event, room})

    {:ok, room}
  end

end
