defmodule HelloWeb.LoginHTML do
  use HelloWeb, :html
  import Phoenix.HTML.Form

  embed_templates "login_html/*"
end
