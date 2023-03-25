defmodule HelloWeb.MerchantHTML do
  use HelloWeb, :html
  import Phoenix.HTML.Form

  embed_templates "merchant_html/*"
end
