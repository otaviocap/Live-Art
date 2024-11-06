defmodule LiveArt.Room.RunningRoom do
  alias LiveArt.Game.Room

  defstruct [
    room: %Room{},
    players: [],
    current_word: nil,
    current_player_drawing: nil
  ]
end
