defmodule DemoWeb.UrGame do
  @special_positions [4, 8, 14]

  def special_position?(index) do
    @special_positions |> Enum.member?(index)
  end

  def possible_moves(state) do
    current_positions =
      case state.current_roll do
        nil -> []
        _ -> Map.get(state, state.current_player)
      end

    current_positions
    |> Enum.map(fn index -> index + state.current_roll end)
    |> Enum.reject(fn index -> Enum.member?(current_positions, index) end)
    |> Enum.reject(fn index -> blocked_by_opponent(state, index) end)
    |> Enum.uniq()
  end

  def roll_update(state) do
    state =
      state
      |> Map.merge(%{current_roll: roll()})

    move_count =
      state
      |> possible_moves
      |> Enum.count()

    if move_count == 0, do: switch_player(state), else: state
  end

  def move_update(state, move_to) do
    player = Map.get(state, state.current_player)

    moved_index =
      player |> Enum.find_index(fn position -> position == move_to - state.current_roll end)

    new_player_positions = List.replace_at(player, moved_index, move_to)

    state =
      state
      |> Map.put(state.current_player, new_player_positions)
      |> Map.put(:current_roll, nil)

    if special_position?(move_to), do: state, else: switch_player(state)
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end

  defp blocked_by_opponent(state, index) do
    opponent_positions = Map.get(state, opponent(state))

    special_position?(index) && Enum.member?(opponent_positions, index)
  end

  defp switch_player(state) do
    state
    |> Map.merge(%{current_player: opponent(state), current_roll: nil})
  end

  defp opponent(state) do
    case state.current_player do
      :alice -> :bob
      _ -> :alice
    end
  end
end
