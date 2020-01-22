defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  @topic "ur"

  def render(assigns) do
    ~L"""
    <div>
      <h1>The Royal Game of Ur</h1>
      <%= if @val do %>
      <span><%= @val %></span>
      <% end %>
      <div>
      <button phx-click="roll">Roll</button>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    DemoWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, val: nil)}
  end

  def handle_event("roll", _, socket) do
    new_roll = roll()
    DemoWeb.Endpoint.broadcast_from(self(), @topic, "roll", %{val: new_roll})
    {:noreply, assign(socket, val: new_roll)}
  end

  def handle_info(%{event: "roll", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  defp roll() do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end
end
