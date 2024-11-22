defmodule LiveArt.Room.RunningRoom do
  alias LiveArt.Room.RunningRoom
  alias LiveArt.Room.RoomPlayer
  alias LiveArt.Game.Room

  defstruct room: %Room{},
            players: [],
            current_word: "",
            current_player_drawing: nil,
            current_drawing: [],
            end_clock: nil

  def add_player(state = %RunningRoom{}, player_name) do
    %{state | players: [%RoomPlayer{name: player_name} | state.players]}
  end

  def add_score(state = %RunningRoom{}, player_name, score) do
    %{
      state
      | players:
          Enum.sort(
            Enum.map(state.players, fn p ->
              %{p | score: p.score + if(p.name == player_name, do: score, else: 0)}
            end),
            &(&1.score > &2.score)
          )
    }
  end

  def add_drawing_stroke(state = %RunningRoom{}, drawing_stroke) do
    %{state | current_drawing: [drawing_stroke | state.current_drawing]}
  end

  def undo_drawing_stroke(state = %RunningRoom{}) do
    if state.current_drawing == [] do
      %{state | current_drawing: []}
    else
      [_hd | current_drawing] = state.current_drawing
      %{state | current_drawing: current_drawing}
    end
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

  def start_game(state = %RunningRoom{}, selected_word) do
    state = %{state | current_player_drawing: hd(Enum.take_random(state.players, 1)).name}
    state = %{state | current_word: selected_word}

    state
  end

  def end_round(state = %RunningRoom{}) do
    state = %{state | current_player_drawing: ""}
    state = %{state | current_word: ""}
    state = %{state | current_drawing: []}

    state
  end

  def has_winner(state = %RunningRoom{}) do
    Enum.count(state.players, fn e -> e.score > 110 end) > 0
  end

  def end_game(state = %RunningRoom{}) do
    players = Enum.map(state.players, fn player -> %{player | score: 0} end)

    %{state | players: players}
  end

  def set_end_clock(state = %RunningRoom{}, timer) do
    %{state | end_clock: timer}
  end


end
