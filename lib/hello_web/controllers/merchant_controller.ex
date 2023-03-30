defmodule HelloWeb.MerchantController do
  use HelloWeb, :controller

  alias Hello.MerchantService

  def index(conn, params) do
    merchants = MerchantService.merchants_list(params)
    render(conn, :index, merchants: merchants)
  end

end
