defmodule Ur2Web.PageController do
  use Ur2Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
