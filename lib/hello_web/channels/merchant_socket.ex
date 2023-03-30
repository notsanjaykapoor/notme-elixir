defmodule HelloWeb.MerchantSocket do
  use Phoenix.Socket
  require Logger

  channel "ping", HelloWeb.PingChannel

  @one_week 604800
  @salt "salt"

  def connect(%{"token" => token}, socket) do
    case _connect_verify(socket, token) do
      {:ok, merchant_id} ->
        socket = assign(socket, :merchant_id, merchant_id)
        {:ok, socket}
      {:error, error} ->
        Logger.error("#{__MODULE__} connect error #{inspect(error)}")
        {:error, error}
    end
  end

  def connect(_, _socket) do
    Logger.error("#{__MODULE__} connect error missing params")
  end

  def id(%{assigns: %{merchant_id: merchant_id}}) do
    "merchant_socket:#{merchant_id}"
  end

  defp _connect_verify(socket, token) do
    Phoenix.Token.verify(socket, @salt, token, max_age: @one_week)
  end
end
