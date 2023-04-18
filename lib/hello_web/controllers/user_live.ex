defmodule HelloWeb.UserLive do
  use HelloWeb, :live_view

  require Logger
  require OpenTelemetry.Tracer, as: Tracer

  alias HelloWeb.{Session, UserTracker}

  @channel_users_local "users_local"

  def handle_info(%{event: "users_online", users: users_map} = _params, socket) do
    Logger.info("controller 'user_live' event 'users_online' #{inspect(users_map)}")

    users_online = users_map
    |> Map.keys()
    |> Enum.sort()

    socket = socket
    |> assign(:users_online, users_online)

    {:noreply, socket}
  end

  def mount(_params, session, socket) do
    Tracer.with_span("controller.user_live.mount") do
      # authenticated route
      {user_handle, user_id} = Session.user_handle_id(session)

      if connected?(socket) do
        Phoenix.PubSub.subscribe(Hello.PubSub, @channel_users_local)
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

end
