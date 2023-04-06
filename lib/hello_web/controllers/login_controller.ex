defmodule HelloWeb.LoginController do
  use HelloWeb, :controller

  def new(conn, _params) do
    render(conn, :new, user: %{handle: "", password: ""})
  end

  def create(conn, params) do
    user_handle = Map.get(params, "user_handle")
    user_id = :rand.uniform(100)

    conn
    |> put_session(:user_id, user_id)
    |> put_session(:user_handle, user_handle)
    |> redirect(to: "/merchants")
    |> halt()
  end

end
