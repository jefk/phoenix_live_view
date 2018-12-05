defmodule DemoWeb.ClockView do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
    <div phx-click="boom">
      <h2>It's <%= strftime!(@date, "%r") %>(<%= @mod %>)</h2>
      <%= for name <- @names do %>
        <br/><%= name %>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, put_date(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_date(socket)}
  end

  defp put_date(socket) do
    {_, {_, _, sec}} = time = :calendar.local_time()

    assign(socket, mod: rem(sec, 10) == 0, date: time, names: ["max", "chris", to_string(rem(sec, 10) == 0)])
  end
end