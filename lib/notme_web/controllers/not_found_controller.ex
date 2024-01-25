defmodule NotmeWeb.NotFoundController do
  use NotmeWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/404")
  end
end
