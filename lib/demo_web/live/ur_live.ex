defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  alias DemoWeb.UrView

  @topic "ur"
  @roll_event "event:roll"

  def render(assigns), do: UrView.render("index.html", assigns)

  def mount(_session, socket) do
    DemoWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, val: nil, cells: initial_cells(), player_a: 0)}
  end

  def handle_event("roll", _, socket) do
    new_roll = roll()
    DemoWeb.Endpoint.broadcast_from(self(), @topic, @roll_event, %{val: new_roll})
    {:noreply, assign(socket, val: new_roll)}
  end

  def handle_event("move", _, %{assigns: %{val: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("move", _, socket) do
    new_player_a = socket.assigns.val + socket.assigns.player_a
    new_cells = update_for_play(new_player_a)
    {:noreply, assign(socket, val: nil, player_a: new_player_a, cells: new_cells)}
  end

  def handle_info(%{event: @roll_event, payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end

  defp initial_cells do
    Enum.flat_map(1..14, &initial_cell/1)
  end

  defp initial_cell(index) do
    case index do
      x when x in 5..12 ->
        [%{name: "s#{index}", occupied: ""}]

      _ ->
        [%{name: "a#{index}", occupied: ""}, %{name: "b#{index}", occupied: ""}]
    end
  end

  defp update_for_play(move) do
    1..14
    |> Enum.flat_map(fn
      index ->
        case index do
          x when x in 5..12 ->
            [%{name: "s#{index}", occupied: if(move == index, do: "a", else: "")}]

          _ ->
            [
              %{name: "a#{index}", occupied: if(move == index, do: "a", else: "")},
              %{name: "b#{index}", occupied: ""}
            ]
        end
    end)
  end
end
