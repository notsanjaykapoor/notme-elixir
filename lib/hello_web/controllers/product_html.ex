defmodule HelloWeb.ProductHTML do
  use HelloWeb, :html
  import Phoenix.HTML.Form

  embed_templates "product_html/*"
end
