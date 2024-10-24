defmodule LiveArtWeb.PageController do
  use LiveArtWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: {LiveArtWeb.Layouts, :app})
  end

  def test(conn, _params) do
    conn
    |> render(:component_test)
  end
end
