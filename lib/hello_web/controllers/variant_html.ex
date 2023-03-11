defmodule HelloWeb.VariantHTML do
  use HelloWeb, :html
  import Phoenix.HTML.Form

  embed_templates "variant_html/*"
end
