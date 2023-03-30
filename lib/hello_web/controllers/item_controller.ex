defmodule HelloWeb.ItemController do
  use HelloWeb, :controller

  alias Hello.ItemService

  def index(conn, params) do
    items = ItemService.items_list(params)
    render(conn, :index, items: items)
  end

end
