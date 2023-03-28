defmodule HelloWeb.ItemController do
  use HelloWeb, :controller

  alias Hello.Catalog

  def index(conn, params) do
    items = Catalog.items_list(params)
    render(conn, :index, items: items)
  end

end
