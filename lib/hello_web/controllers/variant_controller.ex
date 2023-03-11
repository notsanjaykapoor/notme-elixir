defmodule HelloWeb.VariantController do
  use HelloWeb, :controller

  alias Hello.Catalog
  # alias Hello.Catalog.Variant

  def index(conn, params) do
    variants = Catalog.variants_list(params)
    render(conn, :index, variants: variants)
  end

end
