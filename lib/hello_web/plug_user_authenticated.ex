defmodule HelloWeb.PlugUserAuthenticated do
  use HelloWeb, :controller

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:user_id] do
      0 ->
        conn
        |> put_session(:return_to, conn.request_path)
        |> redirect(to: "/login")
        |> halt()
      _ ->
        conn
    end
  end
end
