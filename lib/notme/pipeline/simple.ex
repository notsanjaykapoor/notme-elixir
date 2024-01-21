defmodule Notme.Pipeline.Simple do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    redpanda_host = Application.fetch_env!(:notme, :redpanda_host)
    redpanda_port = Application.fetch_env!(:notme, :redpanda_port)
    redpanda_group = Application.fetch_env!(:notme, :redpanda_group_default)

    topic_name = Application.fetch_env!(:notme, :redpanda_topic_simple)

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
          concurrency: 10
        ]
      ],
      batchers: [
        default: [
          batch_size: 100,
          batch_timeout: 200,
          concurrency: 10
        ]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    message
    |> Message.update_data(fn data -> {data, String.to_integer(data) * 2} end)
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    list = messages |> Enum.map(fn e -> e.data end)
    IO.inspect(list, label: "batch rx")
    messages
  end

  @doc """
  example usage of pipeline defined above
  """
  def push() do
    redpanda_host = Application.fetch_env!(:notme, :redpanda_host)
    redpanda_port = Application.fetch_env!(:notme, :redpanda_port)

    topic_name = Application.fetch_env!(:notme, :redpanda_topic_simple)

    client_id = :client_1
    hosts = ["#{redpanda_host}": redpanda_port]

    :ok = :brod.start_client(hosts, client_id, _client_config = [])
    :ok = :brod.start_producer(client_id, topic_name, _producer_config = [])

    Enum.each(1..1000, fn i ->
      partition = rem(i, 3)
      :ok = :brod.produce_sync(client_id, topic_name, partition, _key="", "#{i}")
    end)

    :ok
  end

end
