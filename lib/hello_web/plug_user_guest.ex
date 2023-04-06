defmodule HelloWeb.PlugUserGuest do
  use HelloWeb, :controller

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:user_id] do
      0 ->
        conn
      _ ->
        conn
        |> redirect(to: "/merchants")
        |> halt()
    end
  end
end
