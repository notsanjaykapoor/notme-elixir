defmodule NotmeWeb.MerchantController do
  use NotmeWeb, :controller

  alias Notme.MerchantService

  def index(conn, params) do
    merchants = MerchantService.merchants_list(params)
    render(conn, :index, merchants: merchants)
  end

end
