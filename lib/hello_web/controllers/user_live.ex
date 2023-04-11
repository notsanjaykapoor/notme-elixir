defmodule HelloWeb.UserLive do
  use HelloWeb, :live_view

  require Logger
  require OpenTelemetry.Tracer, as: Tracer

  alias HelloWeb.UserTracker

  def handle_info(%{event: "users_online"} = _params, socket) do
    Logger.info("user_live#handle_info users_online")

    {:ok, users_map} = UserTracker.users_list()

    users_online = users_map
    |> Map.keys()
    |> Enum.sort()

    socket = socket
    |> assign(:users_online, users_online)

    {:noreply, socket}
  end

  def mount(_params, session, socket) do
    Tracer.with_span("user_live_controller.mount") do
      # authenticated route
      user_handle = Map.get(session, "user_handle")
      user_id = Map.get(session, "user_id")

      topic = "users"

      if connected?(socket) do
        Logger.info("user #{user_handle} topic #{topic} subscribe")

        _users_subscribe(topic)
      end

      {:ok, users_map} = UserTracker.users_list()

      users_online = users_map
      |> Map.keys()
      |> Enum.sort()

      socket = socket
      |> assign(:user_handle, user_handle)
      |> assign(:user_id, user_id)
      |> assign(:users_online, users_online)

      {:ok, socket}
    end
  end

  defp _users_subscribe(topic) do
    Phoenix.PubSub.subscribe(Hello.PubSub, topic)
  end

end
