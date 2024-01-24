defmodule NotmeWeb.LoginController do
  use NotmeWeb, :controller

  alias Notme.Service

  def new(conn, _params) do
    render(conn, :new, user: %{handle: "", password: ""})
  end

  def create(conn, params) do
    user_handle = Map.get(params, "user_handle")
    user_password = Map.get(params, "user_password")
    user_id = :rand.uniform(100)

    return_to = get_session(conn, :return_to) || "/"

    case Service.Login.password_validate(user_password, Application.get_env(:notme, :auth)) do
      {:ok, reason} ->
        dbg(reason)
        conn
        |> delete_session(:return_to)
        |> put_session(:user_id, user_id)
        |> put_session(:user_handle, user_handle)
        |> redirect(to: return_to)
        |> halt()
      {:error, reason} ->
        dbg(reason)
        conn
        |> redirect(to: "/login")
        |> halt()
    end
  end

end
