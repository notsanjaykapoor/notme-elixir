defmodule NotmeWeb.LoginController do
  use NotmeWeb, :controller

  def new(conn, _params) do
    render(conn, :new, user: %{handle: "", password: ""})
  end

  def create(conn, params) do
    user_handle = Map.get(params, "user_handle")
    user_id = :rand.uniform(100)

    return_to = get_session(conn, :return_to) || "/"

    conn
    |> delete_session(:return_to)
    |> put_session(:user_id, user_id)
    |> put_session(:user_handle, user_handle)
    |> redirect(to: return_to)
    |> halt()
  end

end
