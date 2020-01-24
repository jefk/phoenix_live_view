defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def index(conn, _) do
    conn
    |> put_layout(:game)
    |> live_render(DemoWeb.UrLive, session: %{})
  end
end
