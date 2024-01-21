defmodule NotmeWeb.UserTrackerOrig do
  @behaviour Phoenix.Tracker

  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(opts) do
    opts =
      opts
      |> Keyword.put(:name, __MODULE__)
      |> Keyword.put(:pubsub_server, Notme.PubSub)

    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)

    {:ok, %{pubsub_server: server}}
  end

  def handle_diff(changes, state) do
    Logger.info(inspect({"tracked changes", changes}))

    for {_topic, {joins, leaves}} <- changes do
      for {key, _meta} <- joins do
        Logger.info(inspect({"joins", key}))
      end

      for {key, _meta} <- leaves do
        Logger.info(inspect({"leaves", key}))
      end
    end

    {:ok, state}
  end

  @spec list(String.t()) :: [{key :: String.t(), meta :: map()}]
  def list(topic) do
    Phoenix.Tracker.list(__MODULE__, topic)
  end

  def track(%{channel_pid: pid, topic: topic, assigns: %{user_handle: user_handle}}) do
    metadata = %{
      online_at: DateTime.utc_now(),
      user_handle: user_handle,
    }

    Phoenix.Tracker.track(__MODULE__, pid, topic, user_handle, metadata)
  end
end
