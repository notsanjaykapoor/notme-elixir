defmodule HelloWeb.OptionController do
  use HelloWeb, :controller

  alias Hello.OptionService

  def index(conn, params) do
    options = OptionService.options_list(params)
    render(conn, :index, options: options)
  end

end
