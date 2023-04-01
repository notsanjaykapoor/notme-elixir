defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, params) do
    user_id = Map.get(params, "user", :rand.uniform(20))
    user_handle = "user-#{user_id}"

    conn
    |> put_session(:user_id, user_id)
    |> put_session(:user_handle, user_handle)
    |> redirect(to: "/merchants")
    |> halt()
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/merchants")
    |> halt()
  end
end
