defmodule HelloWeb.NodeLive do
  use HelloWeb, :live_view

  require Logger
  require OpenTelemetry.Tracer, as: Tracer

  alias HelloWeb.Session

  @channel_clusters "clusters"

  def handle_info(%{event: "nodes_sync", nodes: nodes} = _params, socket) do
    Logger.info("controller 'user_live' event 'nodes_sync' #{inspect(nodes)}")

    socket = socket
    |> assign(:nodes, nodes)

    {:noreply, socket}
  end

  def mount(_params, session, socket) do
    Tracer.with_span("controller.node_live.mount") do
      if connected?(socket) do
        Phoenix.PubSub.subscribe(Hello.PubSub, @channel_clusters)
      end

      {user_handle, user_id} = Session.user_handle_id(session)

      nodes = [Node.self() | Node.list()]

      socket = socket
      |> assign(:nodes, nodes)
      |> assign(:user_handle, user_handle)
      |> assign(:user_id, user_id)

      {:ok, socket}
    end
  end

end
