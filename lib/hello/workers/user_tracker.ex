defmodule HelloWeb.UserTracker do
  use GenServer

  require Logger

  @user_timer_interval_ms 20_000 # check every x seconds
  @user_offline_interval_sec 60 # seconds with no action before user is considered offline

  # client api

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec user_offline(String.t()) :: {:ok, String.t()}
  def user_offline(user_handle) do
    if user_handle != "guest" do
      GenServer.cast(__MODULE__, {:user_offline, user_handle})
    end

    {:ok, user_handle}
  end

  @spec user_online(String.t(), map) :: {:ok, String.t(), map}
  def user_online(user_handle, user_data) do
    if user_handle != "guest" do
      GenServer.cast(__MODULE__, {:user_online, user_handle, user_data})
    end

    {:ok, user_handle, user_data}
  end

  def users_list() do
    {:ok, GenServer.call(__MODULE__, :users_list)}
  end

  # server callbacks

  @impl true
  @spec init(any) :: {:ok, %{ets_name: atom | :ets.tid()}}
  def init(_map) do
    Process.flag(:trap_exit, true)

    ets_name = :ets.new(:users, [:set, :protected, :named_table])
    user_timer = Process.send_after(self(), :tick, @user_timer_interval_ms)

    Logger.info("user_tracker.init ets_name #{ets_name}")

    {:ok, %{ets_name: ets_name, user_timer: user_timer}}
  end

  @impl true
  def handle_call(:users_list, _from, %{ets_name: ets_name} = state) do
    users_list = :ets.match(ets_name, {:"$1", :_})

    user_map = Enum.reduce(users_list, %{}, fn user_list, user_map ->
      [user_handle | _] = user_list

      Map.put(user_map, user_handle, %{})
    end)

    {:reply, user_map, state}
  end

  @impl true
  def handle_cast({:user_offline, user_handle}, %{ets_name: ets_name} = state) do
    :ets.delete(ets_name, user_handle)

    Logger.info("user_tracker.handle_cast user_offline user_handle #{user_handle}")

    Phoenix.PubSub.broadcast(Hello.PubSub, "users", %{event: "users_online"})

    {:noreply, state}
  end

  def handle_cast({:user_online, user_handle, user_data}, %{ets_name: ets_name} = state) do
    case :ets.lookup(ets_name, user_handle) do
      [] ->
        :ets.insert(ets_name, {user_handle, user_data})

        Phoenix.PubSub.broadcast(Hello.PubSub, "users", %{event: "users_online"})
      _ ->
        :ets.insert(ets_name, {user_handle, user_data})
    end

    Logger.info("user_tracker.handle_cast user_online user_handle #{user_handle}")

    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{ets_name: ets_name} = state) do
    user_timer = Process.send_after(self(), :tick, @user_timer_interval_ms)

    users_list = :ets.match(ets_name, {:"$1", :"$2"})
    time_now = :os.system_time(:seconds)

    users_offline = Enum.filter(users_list, fn [_user_handle, user_map] ->
      time_now - Map.get(user_map, :online_at) > @user_offline_interval_sec
    end)

    for [user_handle, _user_map] = _user_list <- users_offline do
      :ets.delete(ets_name, user_handle)
    end

    if length(users_offline) > 0 do
      # publish message
      Phoenix.PubSub.broadcast(Hello.PubSub, "users", %{event: "users_online"})
    end

    {:noreply, %{state | user_timer: user_timer}}
  end

  @impl true
  def terminate(_reason,  _state) do
    Logger.info("user_tracker.terminate")
  end

end
