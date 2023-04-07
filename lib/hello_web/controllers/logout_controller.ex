defmodule HelloWeb.LogoutController do
  use HelloWeb, :controller

  def index(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/merchants")
    |> halt()
  end

end
