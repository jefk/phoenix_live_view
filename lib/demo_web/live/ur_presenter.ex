defmodule DemoWeb.UrPresenter do
  # This is probably what a view is for??

  def present(%{state: state, other_sockets: other_sockets, socket: %{id: id}}) do
    state
    |> Map.merge(%{
      cells: get_cells(state),
      socket_id: id,
      other_sockets: other_sockets,
      player_message: get_message(state, id)
    })
  end

  defp get_cells(state) do
    1..14
    |> Enum.flat_map(fn index ->
      occupied = occupier(state, index)

      case index do
        x when x in 5..12 ->
          [%{name: "s#{index}", occupied: occupied}]

        _ ->
          [%{name: "a#{index}", occupied: occupied}, %{name: "b#{index}", occupied: ""}]
      end
    end)
  end

  defp get_message(%{alice_socket: alice_socket, bob_socket: bob_socket}, id) do
    case {id, alice_socket, bob_socket} do
      {x, x, _} -> "You are playing as Alice"
      {x, _, x} -> "You are playing as Bob"
      {_, _, nil} -> "Waiting for Bob"
      _ -> "You are #{id}, watching Alice (#{alice_socket}) vs Bob (#{bob_socket})"
    end
  end

  defp occupier(%{alice: alice}, index) do
    case index do
      x when x == alice -> "a"
      _ -> ""
    end
  end
end
