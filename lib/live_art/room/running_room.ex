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

  def add_drawing_stroke(state = %RunningRoom{}, drawing_stroke) do
    %{state | current_drawing: [ drawing_stroke | state.current_drawing ]}
  end

  def undo_drawing_stroke(state = %RunningRoom{}) do
    [_hd | current_drawing] = state.current_drawing

    %{state | current_drawing: current_drawing}
  end

  def clear_drawing(state = %RunningRoom{}) do
    %{state | current_drawing: []}
  end

  def remove_player(state = %RunningRoom{}, player_name) do
    players =
      state.players
      |> Enum.reject(fn e -> e.name == player_name end)

    %{state | players: players}
  end

end
