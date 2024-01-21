defmodule NotmeWeb.LogoutController do
  use NotmeWeb, :controller

  alias NotmeWeb.UserTracker

  def index(conn, _params) do
    UserTracker.user_offline(conn.assigns[:user_handle])

    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/merchants")
    |> halt()
  end

end
