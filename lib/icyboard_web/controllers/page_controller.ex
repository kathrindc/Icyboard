defmodule IcyboardWeb.PageController do
  use IcyboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
