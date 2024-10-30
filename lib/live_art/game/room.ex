defmodule LiveArt.Game.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :password, :string, redact: true
    field :room_id, :string
    field :current_players, :integer
    field :max_players, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:room_id, :current_players, :max_players, :password])
    |> put_change(:current_players, 0)
    |> add_max_players_if_missing()
    |> add_password_if_missing()
    |> add_room_id_if_missing()
    |> validate_max_players()
  end

  def validate_max_players(room) do
    room
    |> validate_number(:max_players, greater_than: 0, less_than_or_equal_to: 20)
  end

  defp add_max_players_if_missing(changeset) do
    case get_field(changeset, :max_players) do
      nil -> put_change(changeset, :max_players, 10)
      _ -> changeset
    end
  end

  defp add_password_if_missing(changeset) do
    case get_field(changeset, :password) do
      nil -> put_change(changeset, :password, "")
      _ -> changeset
    end
  end

  defp add_room_id_if_missing(changeset) do
    room_id = :crypto.strong_rand_bytes(16)
    |> Base.encode16
    |> String.slice(1..6)

    case get_field(changeset, :room_id) do
      nil -> put_change(changeset, :room_id, room_id)
      _ -> changeset
    end
  end
end
