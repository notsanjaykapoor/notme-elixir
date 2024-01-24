defmodule NotmeWeb.MerchantController do
  use NotmeWeb, :controller

  alias Notme.Service

  def index(conn, params) do
    merchants = Service.Merchant.merchants_list(params)
    render(conn, :index, merchants: merchants)
  end

end
