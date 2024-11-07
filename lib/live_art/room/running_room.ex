defmodule LiveArt.Room.RunningRoom do
  alias LiveArt.Room.RunningRoom
  alias LiveArt.Room.RoomPlayer
  alias LiveArt.Game.Room

  defstruct [
    room: %Room{},
    players: [],

    current_word: nil,
    current_player_drawing: nil,
    current_drawing: []
  ]

  def add_player(state = %RunningRoom{}, player_name) do
    %{state | players: [ %RoomPlayer { name: player_name } | state.players ]}
  end

  def remove_player(state = %RunningRoom{}, player_name) do
    players =
      state.players
      |> Enum.reject(fn e -> e.name == player_name end)

    %{state | players: players}
  end

end
