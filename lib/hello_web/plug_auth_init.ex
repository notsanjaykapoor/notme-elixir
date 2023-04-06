defmodule HelloWeb.PlugAuthInit do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    %{ user_handle: user_handle, user_id: user_id} =
      conn
      |> get_session(:user_handle)
      |> case do
        nil -> %{user_handle: "guest", user_id: 0}
        user_handle -> %{user_handle: user_handle, user_id: get_session(conn, :user_id)}
      end

    conn
    |> assign(:user_handle, user_handle)
    |> assign(:user_id, user_id)
  end
end
