defmodule LiveArt.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :room_id, :string
      add :current_players, :integer
      add :max_players, :integer
      add :password, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:rooms, [:room_id])
  end
end
