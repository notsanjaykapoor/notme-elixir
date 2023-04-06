defmodule HelloWeb.RedpandaLive do
  use HelloWeb, :live_view

  alias Hello.ItemService

  def handle_event("item_add", %{"merchant_id" => merchant_id} = _value, socket) do
    user_handle = socket.assigns.user_handle

    product_name = Faker.Superhero.name()

    IO.puts "handle_event item_add user #{user_handle} merchant_id #{merchant_id} product #{product_name}"

    {:ok, value} = Jason.encode(%{merchant_id: merchant_id, product_name: product_name, user_handle: user_handle})

    messages = [{"item_add", value}]

    socket = stream_insert(
      socket, :messages, %{event: "item_add", id: ExULID.ULID.generate(), merchant_id: merchant_id, product_name: product_name}, at: 0
    )


    Kaffe.Producer.produce_sync(_redpanda_topic(), messages)

    {:noreply, socket}
  end

  def handle_event("order_add", %{"merchant_id" => merchant_id} = _value, socket) do
    user_handle = socket.assigns.user_handle

    IO.puts "handle_event order_add user #{user_handle} merchant_id #{merchant_id}"

    # get random item(s)
    items = ItemService.items_list(%{"query" => "merchants:#{merchant_id} sort:random", "limit" => 1})

    messages = Enum.reduce(items, [], fn item, acc ->
      IO.puts "message_producer order_add merchant #{item.merchant_id} item #{item.id}"
      {:ok, value} = Jason.encode(%{id: item.id, user_handle: user_handle})
      [{"order_add", value} | acc]
    end)

    socket = Enum.reduce(items, socket, fn item, socket ->
      stream_insert(socket, :messages, %{event: "order_add", id: item.id, merchant_id: item.merchant_id}, at: 0)
    end)

    Kaffe.Producer.produce_sync(_redpanda_topic(), messages)

    {:noreply, socket}
  end

  def mount(_params, session, socket) do
    # authenticated route
    user_handle = Map.get(session, "user_handle", "guest")
    user_id = Map.get(session, "user_id", 0)

    messages = []

    socket = socket
    |> assign(:user_handle, user_handle)
    |> assign(:user_id, user_id)
    |> stream(:messages, messages)

    {:ok, socket}
  end

  def _redpanda_topic() do
    [topic] = Application.fetch_env!(:redpanda, :topics)

    topic
  end
end
