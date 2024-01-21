defmodule NotmeWeb.MerchantLive do
  use NotmeWeb, :live_view

  alias Notme.{ItemService, MerchantService}
  alias NotmeWeb.Session
  alias NotmeWebApp.Presence

  require Logger
  require OpenTelemetry.Tracer, as: Tracer

  # def handle_event("order_add", _value, socket) do
  #   merchant = socket.assigns.merchant

  #   IO.puts "merchant #{merchant.id} handle_event:order_add"

  #   # get random items
  #   items = ItemService.items_list(%{"query" => "merchants:#{merchant.id} sort:random", "limit" => 10})

  #   # update item qavail
  #   for item <- items do
  #     item = ItemService.item_get!(item.id)
  #     ItemService.item_update(item, %{qavail: item.qavail - 1}) # decrement quantity

  #     Phoenix.PubSub.broadcast(Notme.PubSub, _merchant_topic(merchant.id), %{event: "order_add", id: item.id})
  #   end

  #   {:noreply, socket}
  # end

  def handle_info(%{event: "item_add", id: id} = _params, socket) do
    merchant = socket.assigns.merchant
    user_handle = socket.assigns.user_handle

    Logger.info("controller 'merchant_live' user #{user_handle} merchant #{merchant.id} item_add #{id}")

    item = ItemService.item_get!(id)

    socket = socket
    |> stream_insert(:items, item, at: 0)
    |> assign(:items_count, socket.assigns.items_count + 1)

    {:noreply, socket}
  end

  def handle_info(%{event: "order_add", id: id} = _params, socket) do
    merchant = socket.assigns.merchant
    user_handle = socket.assigns.user_handle

    Logger.info("controller 'merchant_live' user #{user_handle} merchant #{merchant.id} order_add #{id}")

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

    Logger.info(
      "controller 'merchant_live' user #{user_handle} merchant #{merchant.id} presence_diff - joins #{user_joins_count} leaves #{user_leaves_count} online #{Enum.join(users_online, ",")}"
    )

    socket = assign(socket, :users_online, users_online)

    {:noreply, socket}
  end

  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"merchant_id" => merchant_id} = _params, session, socket) do
    Tracer.with_span("controller.merchant_live.mount") do
      {user_handle, user_id} = Session.user_handle_id(session)

      # authenticated route

      merchant = MerchantService.merchant_get!(merchant_id)

      items_search = ItemService.items_list(%{"query" => "merchants:#{merchant_id}", "offset" => "0", "limit" => "100"})
      items_list = items_search.objects

      topic = _merchant_topic(merchant.id)

      Logger.info("user #{user_handle} merchant #{merchant_id} mount")

      if connected?(socket) do
        Logger.info("user #{user_handle} topic #{topic} subscribe")

        _merchant_subscribe(topic)

        Logger.info("user #{user_handle} topic #{topic} presence")

        _merchant_presence_online(topic, user_handle)
      end

      socket = socket
      |> assign(:items_count, length(items_list))
      |> assign(:merchant, merchant)
      |> assign(:user_handle, user_handle)
      |> assign(:user_id, user_id)
      |> assign(:users_online, _merchant_presence_list(topic))
      |> stream(:items, items_list)

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
    Map.keys(Presence.list(topic))
    |> Enum.reduce(%{}, fn user_handle, acc -> Map.put(acc, user_handle, user_handle) end)
    |> Map.keys()
    |> Enum.sort()
  end

  defp _merchant_subscribe(topic) do
    Phoenix.PubSub.subscribe(Notme.PubSub, topic)
  end

  defp _merchant_topic(merchant_id) do
    "merchant:#{merchant_id}"
  end

end
