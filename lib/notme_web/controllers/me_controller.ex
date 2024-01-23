defmodule NotmeWeb.MeController do
  use NotmeWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end

end
