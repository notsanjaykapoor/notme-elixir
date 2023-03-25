defmodule HelloWeb.MerchantController do
  use HelloWeb, :controller

  alias Hello.Catalog

  def index(conn, params) do
    merchants = Catalog.merchants_list(params)
    render(conn, :index, merchants: merchants)
  end

end
