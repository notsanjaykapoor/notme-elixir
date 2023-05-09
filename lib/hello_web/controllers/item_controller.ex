defmodule HelloWeb.ItemController do
  use HelloWeb, :controller

  alias Hello.ItemService
  alias Plug.Conn.Query

  def index(conn, params) do
    search_page = ItemService.items_list(params)

    render(conn, :index, page_nxt: _page_nxt(conn, params, search_page), page_prv: _page_prv(conn, params, search_page), search_page: search_page)
  end

  def _page_nxt(conn, params, search_page) do
    if search_page.offset_nxt > 0 do
        params
        |> Map.put("offset", search_page.offset_nxt)
        |> _url_params(conn.request_path)
    else
      "#"
    end
  end

  def _page_prv(conn, params, search_page) do
    if search_page.offset_prv >= 0 do
        params
        |> Map.put("offset", search_page.offset_prv)
        |> _url_params(conn.request_path)
    else
      "#"
    end
  end

  @doc """
  Constructs url using path and params map
  """
  def _url_params(params, path) do
    "#{path}?#{params |> Query.encode}"
  end

end
