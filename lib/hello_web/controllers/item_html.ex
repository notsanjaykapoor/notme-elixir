defmodule HelloWeb.ItemHTML do
  use HelloWeb, :html
  import Phoenix.HTML.Form

  embed_templates "item_html/*"
end
