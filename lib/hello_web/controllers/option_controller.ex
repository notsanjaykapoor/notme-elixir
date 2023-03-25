defmodule HelloWeb.OptionController do
  use HelloWeb, :controller

  alias Hello.Catalog

  def index(conn, params) do
    options = Catalog.options_list(params)
    render(conn, :index, options: options)
  end

end
