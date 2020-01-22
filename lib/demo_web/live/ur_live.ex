defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  alias DemoWeb.UrView

  @topic "ur"
  @roll_event "event:roll"

  @cells ~w|a4 a3 a2 a1 a14 a13 s5 s6 s7 s8 s9 s10 s11 s12 b4 b3 b2 b1 b14 b13|

  def render(assigns), do: UrView.render("index.html", assigns)

  def mount(_session, socket) do
    DemoWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, val: nil, cells: @cells)}
  end

  def handle_event("roll", _, socket) do
    new_roll = roll()
    DemoWeb.Endpoint.broadcast_from(self(), @topic, @roll_event, %{val: new_roll})
    {:noreply, assign(socket, val: new_roll)}
  end

  def handle_info(%{event: @roll_event, payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end
end
