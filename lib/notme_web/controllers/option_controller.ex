defmodule NotmeWeb.OptionController do
  use NotmeWeb, :controller

  alias Notme.Service

  def index(conn, params) do
    options = Service.Option.options_list(params)
    render(conn, :index, options: options)
  end

end
