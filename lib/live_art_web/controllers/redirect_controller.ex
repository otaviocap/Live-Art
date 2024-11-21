defmodule LiveArtWeb.Controllers.RedirectController do
  use LiveArtWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/")
  end

end
