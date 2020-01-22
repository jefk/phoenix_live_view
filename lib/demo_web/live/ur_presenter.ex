defmodule DemoWeb.UrPresenter do
  alias DemoWeb.UrGame
  # This is probably what a view is for??

  @alice_avatar "👸"
  @bob_avatar "🤴"

  def present(%{state: state, other_sockets: other_sockets, socket: %{id: id}}) do
    my_turn? = get_my_turn(state, id)

    cells =
      state
      |> get_cells
      |> maybe_no_op_clicks(my_turn?)

    state
    |> Map.merge(%{
      cells: cells,
      socket_id: id,
      other_sockets: other_sockets,
      player_message: get_message(state, id),
      my_turn: my_turn?
    })
  end

  defp get_cells(state) do
    possible_moves = UrGame.possible_moves(state)

    shared_cells =
      Enum.map(5..12, fn index ->
        alice_in = if Map.get(state, :alice) |> Enum.member?(index), do: @alice_avatar, else: nil
        bob_in = if Map.get(state, :bob) |> Enum.member?(index), do: @bob_avatar, else: nil
        possible? = Enum.member?(possible_moves, index)

        class_names =
          [
            if(possible?, do: "possible", else: nil),
            if(UrGame.special_position?(index), do: "special", else: nil),
            if(index == 0 || index == 15, do: "holding", else: nil)
          ]
          |> Enum.reject(&is_nil/1)
          |> Enum.join(" ")

        phx_click = if possible?, do: "move", else: ""

        %{
          name: "s#{index}",
          label: "s#{index}",
          occupied: alice_in || bob_in,
          class_names: class_names,
          phx_click: phx_click,
          index: index,
          holding: false
        }
      end)

    shared_cells
    |> Enum.concat(get_cells(state, :alice))
    |> Enum.concat(get_cells(state, :bob))
  end

  defp get_cells(state, player) do
    possible_moves = UrGame.possible_moves(state)
    prefix = player |> Atom.to_string() |> String.first()

    emoji =
      case player do
        :alice -> @alice_avatar
        _ -> @bob_avatar
      end

    Enum.concat(0..4, 13..15)
    |> Enum.map(fn index ->
      player_in_cell = if Map.get(state, player) |> Enum.member?(index), do: emoji, else: nil
      possible? = Enum.member?(possible_moves, index) && state.current_player == player

      class_names =
        [
          if(possible?, do: "possible", else: nil),
          if(UrGame.special_position?(index), do: "special", else: nil),
          if(index == 0 || index == 15, do: "holding", else: nil)
        ]
        |> Enum.reject(&is_nil/1)
        |> Enum.join(" ")

      phx_click = if possible?, do: "move", else: ""

      %{
        name: "#{prefix}#{index}",
        label:
          case index do
            0 -> "start"
            15 -> "home"
            _ -> "#{prefix}#{index}"
          end,
        occupied: player_in_cell,
        class_names: class_names,
        phx_click: phx_click,
        count: count_at(Map.get(state, player), index),
        index: index,
        holding: index == 0 || index == 15
      }
    end)
  end

  defp get_message(%{alice_socket: alice_socket, bob_socket: bob_socket}, id) do
    case {id, alice_socket, bob_socket} do
      {x, x, _} -> "You are playing as Alice"
      {x, _, x} -> "You are playing as Bob"
      {_, _, nil} -> "Waiting for Bob to join"
      _ -> "You are #{id}, watching Alice (#{alice_socket}) vs Bob (#{bob_socket})"
    end
  end

  defp get_my_turn(state, id) do
    me(state, id) == state.current_player
  end

  defp me(%{alice_socket: alice_socket, bob_socket: bob_socket}, id) do
    case {id, alice_socket, bob_socket} do
      {x, x, _} -> :alice
      {x, _, x} -> :bob
      _ -> nil
    end
  end

  defp maybe_no_op_clicks(cells, my_turn?) do
    if my_turn? do
      cells
    else
      cells
      |> Enum.map(fn cell -> Map.put(cell, :phx_click, "") end)
    end
  end

  defp count_at(positions, at) do
    Enum.count(positions, fn position -> position == at end)
  end
end
