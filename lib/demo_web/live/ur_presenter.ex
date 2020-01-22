defmodule DemoWeb.UrPresenter do
  # This is probably what a view is for??

  def present(%{state: state, other_sockets: other_sockets, socket: %{id: id}}) do
    state
    |> Map.merge(%{
      cells: get_cells(state),
      socket_id: id,
      other_sockets: other_sockets,
      player_message: get_message(state, id),
      my_turn: get_my_turn(state, id)
    })
  end

  defp get_cells(state) do
    1..14
    |> Enum.flat_map(fn index ->
      alice_in = if state.alice == index, do: "a", else: nil
      bob_in = if state.bob == index, do: "b", else: nil

      case index do
        x when x in 5..12 ->
          [%{name: "s#{index}", occupied: alice_in || bob_in}]

        _ ->
          [%{name: "a#{index}", occupied: alice_in}, %{name: "b#{index}", occupied: bob_in}]
      end
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
end
