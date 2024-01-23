defmodule Notme.Pipeline.Inventory do
  use Broadway

  require Logger

  alias Broadway.Message
  alias Notme.Pipeline
  alias Notme.Pipeline.InventoryHandler

  def start_link(_opts) do
    redpanda_host = Application.fetch_env!(:notme, :redpanda_host)
    redpanda_port = Application.fetch_env!(:notme, :redpanda_port)
    redpanda_group = Application.fetch_env!(:notme, :redpanda_group)

    topic_name = Application.fetch_env!(:notme, :redpanda_topic_inventory)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayKafka.Producer,
           [
             hosts: ["#{redpanda_host}": redpanda_port],
             group_id: redpanda_group,
             topics: [topic_name]
           ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ]
    )
  end

  @impl true
  @spec handle_message(any, Message.t(), any) :: Message.t()
  def handle_message(_, message, _) do
    IO.inspect(message) # debug

    {:ok, message_data} = Jason.decode(message.data)

    _handle_data(message_data)

    message
  end

  def _handle_data(%{"event" => "item_add", "merchant_id" => _merchant_id, "product_name" => _product_name} = data) do
    Logger.info("pipeline 'inventory' message 'item_add' #{inspect(data)}")

    InventoryHandler.item_add(data)
  end

  def _handle_data(data) do
    Logger.info("pipeline 'inventory' message unhandled #{inspect(data)}")
  end

  @spec push_items(integer, integer) :: any
  def push_items(merchant_id, item_count) do
    Logger.info("pipeline 'inventory' push_items merchant #{merchant_id} items #{item_count}")

    topic = Application.fetch_env!(:notme, :redpanda_topic_inventory)

    Pipeline.start_producer(topic)

    for _i <- Enum.to_list(1..item_count) do
      product_name = Faker.Superhero.name()
      value_map = %{event: "item_add", id: ExULID.ULID.generate(), merchant_id: merchant_id, product_name: product_name}
      {:ok, value} = Jason.encode(value_map)

      Pipeline.push(topic, _paritition=0, _key="", value)
    end
  end

end
