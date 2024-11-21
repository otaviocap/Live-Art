defmodule LiveArt.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  require Logger
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

  def add_player(room_id) do
    Repo.transaction(fn ->
      room = Room
        |> where(room_id: ^room_id)
        |> Repo.one()

      changeset = Ecto.Changeset.change(room, current_players: room.current_players + 1)

      Repo.update(changeset)
      |> broadcast(:room_updated)
    end)
  end

  def remove_player(room_id) do
    Repo.transaction(fn ->
      room = Room
        |> where(room_id: ^room_id)
        |> Repo.one()

      changeset = Ecto.Changeset.change(room, current_players: room.current_players - 1)

      Repo.update(changeset)
      |> broadcast(:room_updated)
    end)
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
