defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  alias DemoWeb.UrView
  alias DemoWeb.UrPresenter

  @topic "ur"
  @initial_state %{
    current_roll: nil,
    alice_socket: nil,
    bob_socket: nil,
    current_player: :alice,
    alice: Enum.map(1..7, fn _ -> 0 end),
    bob: Enum.map(1..7, fn _ -> 0 end)
  }

  def render(assigns) do
    UrView.render("index.html", UrPresenter.present(assigns))
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

  def handle_event("move", %{"moveto" => move_to}, socket) do
    socket.assigns.state
    |> move_update(String.to_integer(move_to))
    |> broadcast_and_assign_state(socket)
  end

  def handle_event("select-bob", %{"bob" => bob_socket}, socket) do
    socket.assigns.state
    |> Map.merge(%{alice_socket: socket.id, bob_socket: bob_socket})
    |> broadcast_and_assign_state(socket)
  end

  def handle_info(%{event: "update:state", payload: state}, socket) do
    {:noreply, assign(socket, :state, state)}
  end

  def handle_info(%{event: "event:join", payload: %{socket_id: socket_id}}, socket) do
    other_sockets = (socket.assigns.other_sockets ++ [socket_id]) |> Enum.uniq()
    {:noreply, assign(socket, :other_sockets, other_sockets)}
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end

  defp roll_update(state) do
    state
    |> Map.merge(%{current_roll: roll()})
  end

  defp move_update(state, move_to) do
    player = Map.get(state, state.current_player)

    moved_index =
      player |> Enum.find_index(fn position -> position == move_to - state.current_roll end)

    new_player = List.replace_at(player, moved_index, move_to)

    new_current_player =
      case state.current_player do
        :alice -> :bob
        _ -> :alice
      end

    state
    |> Map.put(state.current_player, new_player)
    |> Map.merge(%{current_roll: nil, current_player: new_current_player})
  end

  defp broadcast_and_assign_state(state, socket) do
    DemoWeb.Endpoint.broadcast_from(self(), @topic, "update:state", state)
    {:noreply, assign(socket, :state, state)}
  end
end
