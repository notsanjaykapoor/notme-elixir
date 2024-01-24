defmodule NotmeWeb.ItemController do
  use NotmeWeb, :controller

  alias Notme.Service
  alias Plug.Conn.Query

  def index(conn, params) do
    search_page = Service.Item.items_list(params)

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
        |> _url_offset(search_page.offset_prv)
        # |> Map.put("offset", search_page.offset_prv)
        |> _url_params(conn.request_path)
    else
      "#"
    end
  end

  def _url_offset(params, offset) do
    if offset > 0 do
      Map.put(params, "offset", offset)
    else
      Map.delete(params, "offset")
    end
  end

  @doc """
  Constructs url using path and params map
  """
  def _url_params(params, path) do
    "#{path}?#{params |> Query.encode}"
  end

end
