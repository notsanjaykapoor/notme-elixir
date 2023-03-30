defmodule HelloWeb.MerchantLive do
  use HelloWeb, :live_view
  # use Phoenix.LiveView

  alias Hello.ItemService
  alias Hello.MerchantService

  # def render(assigns) do
  #   ~H"""
  #   test
  #   <button phx-click="update">+</button>
  #   """
  # end

  def handle_event("update", _value, socket) do
    merchant = socket.assigns.merchant

    IO.puts "merchant #{merchant.id} handle_event:update"

    # get item and update qavail
    items = ItemService.items_list(%{"query" => "merchants:#{merchant.id} sort:random", "limit" => 10})

    for item <- items do
      item = ItemService.item_get!(item.id)
      ItemService.item_update(item, %{qavail: item.qavail - 1})
      # ItemService.item_update(item, %{qavail: item.qavail - :rand.uniform(3)})

      Phoenix.PubSub.broadcast(Hello.PubSub, "merchant:#{merchant.id}", %{event: "item_update", id: item.id})
    end

    # socket = Enum.reduce(items, socket, fn item, socket ->
    #   IO.puts "merchant #{merchant.id} item #{item.id} changed"
    #   item = Map.put(item, :qavail, item.qavail - :rand.uniform(item.qavail))
    #   stream_insert(socket, :items, item)
    # end)

    {:noreply, socket}
  end

  def handle_info(%{event: "item_update", id: id} = _params, socket) do
    merchant = socket.assigns.merchant

    IO.puts "merchant #{merchant.id} item_update #{id}"

    item = ItemService.item_get!(id)
    socket = stream_insert(socket, :items, item)

    {:noreply, socket}
  end

  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"merchant_id" => merchant_id} = _params, _session, socket) do
    merchant = MerchantService.merchant_get!(merchant_id)
    items = ItemService.items_list(%{"query" => "merchants:#{merchant_id}"})

    IO.puts "merchant #{merchant_id} mount"

    if connected?(socket) do
      IO.puts "merchant #{merchant_id} subscribe"
      _merchant_subscribe(merchant)
    end

    socket = socket
    |> assign(:merchant, merchant)
    |> stream(:items, items)

    {:ok, socket}
  end

  defp _merchant_subscribe(merchant) do
    Phoenix.PubSub.subscribe(Hello.PubSub, "merchant:#{merchant.id}")
    # HelloWeb.Endpoint.subscribe("merchant:#{merchant.id}")
  end

end
