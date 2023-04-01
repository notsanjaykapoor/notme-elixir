defmodule HelloWeb.PlugAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_handle =
      conn
      |> get_session(:user_handle)
      |> case do
        nil -> "guest"
        handle -> handle
      end

    assign(conn, :user_handle, user_handle)
  end
end
