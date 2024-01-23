defmodule NotmeWeb.MeController do
  use NotmeWeb, :controller

  def index(conn, _params) do
    version = Application.get_env(:notme, :version)
    render(conn, :index, layout: false, version: version)
  end

end
