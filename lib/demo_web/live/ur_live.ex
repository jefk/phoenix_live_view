defmodule DemoWeb.UrLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <h1>The Royal Game of Ur</h1>
      <%= if @val do %>
      <span><%= @val %></span>
      <%= end %>
      <div>
      <button phx-click="roll">Roll</button>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, val: false)}
  end

  def handle_event("roll", _, socket) do
    {:noreply, update(socket, :val, &roll/1)}
  end

  defp roll(_) do
    Enum.sum([Enum.random(0..1), Enum.random(0..1), Enum.random(0..1), Enum.random(0..1)])
  end
end
