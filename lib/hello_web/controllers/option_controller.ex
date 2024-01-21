defmodule NotmeWeb.OptionController do
  use NotmeWeb, :controller

  alias Notme.OptionService

  def index(conn, params) do
    options = OptionService.options_list(params)
    render(conn, :index, options: options)
  end

end
