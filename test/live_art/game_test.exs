defmodule LiveArt.GameTest do
  use LiveArt.DataCase

  alias LiveArt.Game

  describe "rooms" do
    alias LiveArt.Game.Room

    import LiveArt.GameFixtures

    @invalid_attrs %{password: nil, room_id: nil, current_players: nil, max_players: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Game.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Game.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{password: "some password", room_id: "some room_id", current_players: 42, max_players: 42}

      assert {:ok, %Room{} = room} = Game.create_room(valid_attrs)
      assert room.password == "some password"
      assert room.room_id == "some room_id"
      assert room.current_players == 42
      assert room.max_players == 42
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{password: "some updated password", room_id: "some updated room_id", current_players: 43, max_players: 43}

      assert {:ok, %Room{} = room} = Game.update_room(room, update_attrs)
      assert room.password == "some updated password"
      assert room.room_id == "some updated room_id"
      assert room.current_players == 43
      assert room.max_players == 43
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_room(room, @invalid_attrs)
      assert room == Game.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Game.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Game.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Game.change_room(room)
    end
  end
end
