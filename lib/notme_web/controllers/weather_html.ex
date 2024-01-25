defmodule NotmeWeb.WeatherHTML do
  use NotmeWeb, :html
  import Phoenix.HTML.Form

  embed_templates "weather_html/*"
end
