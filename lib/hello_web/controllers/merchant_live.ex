defmodule HelloWeb.MerchantLive do
  use HelloWeb, :live_view
  # use Phoenix.LiveView

  alias Hello.{ItemService, MerchantService}

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
      ItemService.item_update(item, %{qavail: item.qavail - 1}) # decrement quantity
      # ItemService.item_update(item, %{qavail: item.qavail - :rand.uniform(3)}) # random quantity updates

      Phoenix.PubSub.broadcast(Hello.PubSub, "merchant:#{merchant.id}", %{event: "item_update", id: item.id})
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "item_update", id: id} = _params, socket) do
    merchant = socket.assigns.merchant
    user_id = socket.assigns.user_id

    IO.puts "user #{user_id} merchant #{merchant.id} item_update #{id}"

    item = ItemService.item_get!(id)
    socket = stream_insert(socket, :items, item)

    {:noreply, socket}
  end

  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"merchant_id" => merchant_id} = _params, session, socket) do
    items = ItemService.items_list(%{"query" => "merchants:#{merchant_id}"})
    merchant = MerchantService.merchant_get!(merchant_id)

    user_handle = Map.get(session, "user_handle")
    user_id = Map.get(session, "user_id")

    IO.puts "user #{user_id} merchant #{merchant_id} mount"

    if connected?(socket) do
      IO.puts "user #{user_id} merchant #{merchant_id} subscribe"
      _merchant_subscribe(merchant_id)
    end

    socket = socket
    |> assign(:merchant, merchant)
    |> stream(:items, items)
    |> assign(:user_handle, user_handle)
    |> assign(:user_id, user_id)

    {:ok, socket}
  end

  defp _merchant_subscribe(merchant_id) do
    Phoenix.PubSub.subscribe(Hello.PubSub, "merchant:#{merchant_id}")
    # HelloWeb.Endpoint.subscribe("merchant:#{merchant.id}")
  end

end
