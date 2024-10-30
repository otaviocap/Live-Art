defmodule LiveArt.GameFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveArt.Game` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        current_players: 42,
        max_players: 42,
        password: "some password",
        room_id: "some room_id"
      })
      |> LiveArt.Game.create_room()

    room
  end
end
