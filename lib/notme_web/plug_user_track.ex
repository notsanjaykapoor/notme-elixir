defmodule NotmeWeb.PlugUserTrack do
  use NotmeWeb, :controller

  import Plug.Conn

  alias NotmeWeb.UserTracker

  def init(opts), do: opts

  def call(conn, _opts) do
    UserTracker.user_online(
      conn.assigns[:user_handle],
      %{
        online_at: :os.system_time(:seconds),
        path: conn.request_path,
      }
    )

    conn
  end
end
