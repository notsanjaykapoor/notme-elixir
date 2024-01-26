defmodule NotmeWeb.WeatherController do
  use NotmeWeb, :controller

  alias Notme.Service

  def index(conn, params) do
    city = Map.get(params, "city", "")

    weather_token = Application.get_env(:notme, :weather_token)
    weather_uri = Application.get_env(:notme, :weather_uri)
    weather_params = [appid: weather_token, mode: "json", units: "imperial", q: city]

    dbg([weather_token, weather_uri])

    case Req.get(weather_uri, params: weather_params) do
      {:ok, %Req.Response{status: 200, body: body} = _response} ->
        dbg(["ok", 200, body])
        name = Map.get(body, "name", "")
        sys = Map.get(body, "sys", {})
        temp = Map.get(body, "main", %{})
        [weather | _] = Map.get(body, "weather", [%{}])
        render(conn, :index, %{city: city, name: name, sys: sys, temp: temp, weather: weather})
      {:ok, %Req.Response{status: 400, body: body} = _response} ->
        dbg(["ok", "nothing", body])
        render(conn, :index, %{city: city, name: nil})
      {:ok, %Req.Response{status: 404, body: body} = _response} ->
        dbg(["ok", body])
        render(conn, :index, %{city: city, name: nil})
      {:ok, %Req.Response{status: status, body: body} = _response} ->
        dbg(["ok", status, body])
        render(conn, :index, %{city: city, name: nil})
      _ ->
        render(conn, :index, %{city: city, name: nil})
    end
  end

  def create(conn, params) do
    user_handle = Map.get(params, "user_handle")
    user_password = Map.get(params, "user_password")
    user_id = :rand.uniform(100)

    return_to = get_session(conn, :return_to) || "/"

    case Service.Login.password_validate(user_password, Application.get_env(:notme, :auth)) do
      {:ok, reason} ->
        dbg(reason)
        conn
        |> delete_session(:return_to)
        |> put_session(:user_id, user_id)
        |> put_session(:user_handle, user_handle)
        |> redirect(to: return_to)
        |> halt()
      {:error, reason} ->
        dbg(reason)
        conn
        |> redirect(to: "/login")
        |> halt()
    end
  end

end
