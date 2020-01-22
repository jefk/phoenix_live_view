defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  alias DemoWeb.UrView

  @topic "ur"
  @initial_state %{
    current_roll: nil,
    alice_socket: nil,
    bob_socket: nil,
    alice: 0,
    bob: 0
  }

  def render(%{state: state, other_sockets: other_sockets, socket: %{id: id}}) do
    template_assigns =
      state
      |> Map.merge(%{
        cells: get_cells(state),
        socket_id: id,
        other_sockets: other_sockets,
        player_message: get_message(state, id)
      })

    UrView.render("index.html", template_assigns)
  end

  def mount(_session, socket) do
    DemoWeb.Endpoint.broadcast_from(self(), @topic, "event:join", %{socket_id: socket.id})

    DemoWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, %{state: @initial_state, other_sockets: []})}
  end

  def handle_event("roll", _, socket) do
    socket.assigns.state
    |> roll_update
    |> broadcast_and_assign_state(socket)
  end

  def handle_event("move", _, socket) do
    socket.assigns.state
    |> move_update
    |> broadcast_and_assign_state(socket)
  end

  def handle_event("select-bob", %{"bob" => bob_socket}, socket) do
    socket.assigns.state
    |> Map.merge(%{alice_socket: socket.id, bob_socket: bob_socket})
    |> broadcast_and_assign_state(socket)
  end

  def handle_info(%{event: "update:state", payload: state}, socket) do
    IO.puts("handling update:state")
    {:noreply, assign(socket, :state, state)}
  end

  def handle_info(%{event: "event:join", payload: %{socket_id: socket_id}}, socket) do
    other_sockets = (socket.assigns.other_sockets ++ [socket_id]) |> Enum.uniq()
    {:noreply, assign(socket, :other_sockets, other_sockets)}
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
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

  defp roll_update(state) do
    state
    |> Map.merge(%{current_roll: roll()})
  end

  defp move_update(state) do
    alice = state.alice + state.current_roll

    state |> Map.merge(%{alice: alice, current_roll: nil})
  end

  defp occupier(%{alice: alice}, index) do
    case index do
      x when x == alice -> "a"
      _ -> ""
    end
  end

  defp broadcast_and_assign_state(state, socket) do
    DemoWeb.Endpoint.broadcast_from(self(), @topic, "update:state", state)
    {:noreply, assign(socket, :state, state)}
  end

  defp get_message(%{alice_socket: alice_socket, bob_socket: bob_socket}, id) do
    case {id, alice_socket, bob_socket} do
      {x, x, _} -> "You are playing as Alice"
      {x, _, x} -> "You are playing as Bob"
      {_, _, nil} -> "Waiting for Bob"
      _ -> "You are #{id}, watching Alice (#{alice_socket}) vs Bob (#{bob_socket})"
    end
  end
end
