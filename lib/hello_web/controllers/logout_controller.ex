defmodule HelloWeb.LogoutController do
  use HelloWeb, :controller

  alias HelloWeb.UserTracker

  def index(conn, _params) do
    UserTracker.user_offline(conn.assigns[:user_handle])

    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/merchants")
    |> halt()
  end

end
