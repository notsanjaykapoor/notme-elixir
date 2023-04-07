defmodule HelloWeb.MerchantLive do
  use HelloWeb, :live_view

  alias Hello.{ItemService, MerchantService}
  alias HelloWebApp.Presence

  require OpenTelemetry.Tracer, as: Tracer

  # def render(assigns) do
  #   ~H"""
  #   test
  #   <button phx-click="update">+</button>
  #   """
  # end

  def handle_event("order_add", _value, socket) do
    merchant = socket.assigns.merchant

    IO.puts "merchant #{merchant.id} handle_event:order_add"

    # get random items
    items = ItemService.items_list(%{"query" => "merchants:#{merchant.id} sort:random", "limit" => 10})

    # update item qavail
    for item <- items do
      item = ItemService.item_get!(item.id)
      ItemService.item_update(item, %{qavail: item.qavail - 1}) # decrement quantity
      # ItemService.item_update(item, %{qavail: item.qavail - :rand.uniform(3)}) # random quantity updates

      Phoenix.PubSub.broadcast(Hello.PubSub, _merchant_topic(merchant.id), %{event: "order_add", id: item.id})
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "item_add", id: id} = _params, socket) do
    merchant = socket.assigns.merchant
    user_handle = socket.assigns.user_handle

    IO.puts "user #{user_handle} merchant #{merchant.id} item_add #{id}"

    item = ItemService.item_get!(id)
    socket = stream_insert(socket, :items, item, at: 0)

    {:noreply, socket}
  end

  def handle_info(%{event: "order_add", id: id} = _params, socket) do
    merchant = socket.assigns.merchant
    user_handle = socket.assigns.user_handle

    IO.puts "user #{user_handle} merchant #{merchant.id} order_add #{id}"

    item = ItemService.item_get!(id)
    socket = stream_insert(socket, :items, item)

    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: payload, topic: topic} = _params, socket) do
    merchant = socket.assigns.merchant
    user_handle = socket.assigns.user_handle

    user_joins_count = length(Map.keys(payload.joins))
    user_leaves_count = length(Map.keys(payload.leaves))

    users_online = _merchant_presence_list(topic)

    IO.puts "user #{user_handle} merchant #{merchant.id} presence_diff - joins #{user_joins_count} leaves #{user_leaves_count} ids online #{Enum.join(users_online, ",")}"

    socket = assign(socket, :users_online, users_online)

    {:noreply, socket}
  end

  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"merchant_id" => merchant_id} = _params, session, socket) do
    Tracer.with_span("merchant_live_controller.mount") do
      # authenticated route
      items = ItemService.items_list(%{"query" => "merchants:#{merchant_id}"})
      merchant = MerchantService.merchant_get!(merchant_id)

      user_handle = Map.get(session, "user_handle", "guest")
      user_id = Map.get(session, "user_id", 0)

      topic = _merchant_topic(merchant.id)

      IO.puts "user #{user_handle} merchant #{merchant_id} mount"

      if connected?(socket) do
        IO.puts "user #{user_handle} topic #{topic} subscribe"

        _merchant_subscribe(topic)

        IO.puts "user #{user_handle} topic #{topic} presence"
        _merchant_presence_online(topic, user_handle)
      end

      socket = socket
      |> assign(:merchant, merchant)
      |> assign(:user_handle, user_handle)
      |> assign(:user_id, user_id)
      |> assign(:users_online, _merchant_presence_list(topic))
      |> stream(:items, items)

      {:ok, socket}
    end
  end

  defp _merchant_presence_online(topic, user_handle) do
    {:ok, _} = Presence.track(
      self(),
      topic,
      user_handle,
      %{
        online_at: inspect(System.system_time(:second)),
      }
    )
  end

  defp _merchant_presence_list(topic) do
    presence_keys = Map.keys(Presence.list(topic))

    Enum.sort(
      Map.keys(
        Enum.reduce(presence_keys, %{}, fn user_handle, acc -> Map.put(acc, user_handle, user_handle) end)
      )
    )
  end

  defp _merchant_subscribe(topic) do
    Phoenix.PubSub.subscribe(Hello.PubSub, topic)
  end

  defp _merchant_topic(merchant_id) do
    "merchant:#{merchant_id}"
  end

end
