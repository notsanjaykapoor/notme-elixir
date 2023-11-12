defmodule HelloWeb.UserHTML do
  use HelloWeb, :html
  import Phoenix.HTML.Form

  embed_templates "user_html/*"
end
