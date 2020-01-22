defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  alias DemoWeb.UrView

  @topic "ur"
  @roll_event "event:roll"
  @initial_state %{
    current_roll: nil,
    alice: Enum.map(1..14, fn _ -> false end),
    bob: Enum.map(1..14, fn _ -> false end)
  }

  def render(%{state: state}) do
    template_assigns = state |> Map.merge(%{cells: get_cells(state)})
    UrView.render("index.html", template_assigns)
  end

  def mount(_session, socket) do
    DemoWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, %{state: @initial_state})}
  end

  def handle_event("roll", _, %{assigns: %{state: state}} = socket) do
    state = state |> roll_update
    DemoWeb.Endpoint.broadcast_from(self(), @topic, @roll_event, state)
    {:noreply, assign(socket, %{state: state})}
  end

  def handle_event("move", _, socket) do
    {:noreply, socket}
  end

  def handle_info(%{event: @roll_event, payload: state}, socket) do
    IO.inspect('handle')
    {:noreply, assign(socket, state)}
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end

  defp get_cells(_state) do
    1..14
    |> Enum.flat_map(fn index ->
      case index do
        x when x in 5..12 ->
          [%{name: "s#{index}", occupied: ""}]

        _ ->
          [%{name: "a#{index}", occupied: ""}, %{name: "b#{index}", occupied: ""}]
      end
    end)
  end

  defp roll_update(state) do
    state
    |> Map.merge(%{current_roll: roll()})
  end
end
