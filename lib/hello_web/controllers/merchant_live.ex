defmodule HelloWeb.MerchantLive do
  use HelloWeb, :live_view
  # use Phoenix.LiveView

  alias Hello.{ItemService, MerchantService}
  alias HelloWebApp.Presence

  # def render(assigns) do
  #   ~H"""
  #   test
  #   <button phx-click="update">+</button>
  #   """
  # end

  @spec handle_event(
          <<_::48>>,
          any,
          atom
          | %{
              :assigns => atom | %{:merchant => atom | map, optional(any) => any},
              optional(any) => any
            }
        ) :: {:noreply, atom | %{:assigns => atom | map, optional(any) => any}}
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

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: payload, topic: topic} = _params, socket) do
    merchant = socket.assigns.merchant
    user_id = socket.assigns.user_id

    user_joins_count = length(Map.keys(payload.joins))
    user_leaves_count = length(Map.keys(payload.leaves))

    users_online =_merchant_presence_list(topic)

    IO.puts "user #{user_id} merchant #{merchant.id} presence_diff - joins #{user_joins_count} leaves #{user_leaves_count} ids online #{Enum.join(users_online, ",")}"

    socket = assign(socket, :users_online, users_online)

    {:noreply, socket}
  end

  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"merchant_id" => merchant_id} = _params, session, socket) do
    items = ItemService.items_list(%{"query" => "merchants:#{merchant_id}"})
    merchant = MerchantService.merchant_get!(merchant_id)

    user_handle = Map.get(session, "user_handle", "guest")
    user_id = Map.get(session, "user_id", 0)

    topic = _merchant_topic(merchant.id)

    IO.puts "user #{user_handle} merchant #{merchant_id} mount"

    if connected?(socket) do
      IO.puts "user #{user_id} topic #{topic} subscribe"

      _merchant_subscribe(topic)

      if user_id != 0 do
        IO.puts "user #{user_id} topic #{topic} presence"
        _merchant_presence_online(topic, user_id, user_handle)
      end
    end

    socket = socket
    |> assign(:merchant, merchant)
    |> stream(:items, items)
    |> assign(:user_handle, user_handle)
    |> assign(:user_id, user_id)
    |> assign(:users_online, _merchant_presence_list(topic))

    {:ok, socket}
  end

  defp _merchant_presence_online(topic, user_id, user_handle) do
    {:ok, _} = Presence.track(
      self(),
      topic,
      user_id,
      %{
        online_at: inspect(System.system_time(:second)),
        user_handle: user_handle,
      }
    )
  end

  defp _merchant_presence_list(topic) do
    presence_keys = Map.keys(Presence.list(topic))

    Enum.sort(
      Map.keys(
        Enum.reduce(presence_keys, %{}, fn user_id, acc -> Map.put(acc, String.to_integer(user_id), String.to_integer(user_id)) end)
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
