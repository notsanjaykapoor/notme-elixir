defmodule Notme.Pipeline do

  @spec push(String.t(), integer(), String.t(), String.t()) :: any
  @doc """
  Push a single message on the specified topic and partition.

  The producer for the topic must already be started with a call to start_producer/1.
  """
  def push(topic_name, partition, key, value) do
    :brod.produce_sync(_rp_client(), topic_name, partition, _key=key, value)
  end

  @spec start_producer(String.t()) :: :ok
  @doc """
  Start producer on the specified topic.  The producer must be started before sending messages
  using push/4.
  """
  def start_producer(topic_name) do
    hosts = ["#{_rp_host()}": _rp_port()]

    :ok = :brod.start_client(hosts, _rp_client(), _client_config = [])
    :ok = :brod.start_producer(_rp_client(), topic_name, _producer_config = [])

    :ok
  end


  def _rp_client() do
    :client_1
  end

  def _rp_host() do
    Application.fetch_env!(:notme, :redpanda_host)
  end

  def _rp_port() do
    Application.fetch_env!(:notme, :redpanda_port)
  end

end
