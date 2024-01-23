defmodule NotmeWeb.PageController do
  use NotmeWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # render(conn, :home, layout: false)

    home = Application.get_env(:notme, :home)

    if home == "me" do
      redirect(conn, to: "/me")
    else
      redirect(conn, to: "/merchants")
    end
  end
end
