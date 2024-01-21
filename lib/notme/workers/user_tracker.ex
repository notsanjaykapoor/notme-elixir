defmodule NotmeWeb.UserTracker do
  @moduledoc """
  Implements basic user tracking/presense with support for clustered nodes.  The implementation uses 2 pubsub
  channels "users_local" and "users_gossip".

  The "users_local" channel tracks user state on a single node, using a genserver and ets tables to track
  user state on the local node.  When user state changes, the changes are broadcast to local subscribers
  on the "users_local" channel, and to other nodes on the "users_gossip" channel.

  The "users_gossip" channel syncs user state between nodes.  Each "users_sync" message contains user
  state for a specific clustered node.  This state is compared to the current state in ets, and
  the resulting diff is applied.

  The genserver also handles kernel nodeup and nodedown events to update user state when nodes come and go.
  """

  use GenServer

  require Logger

  @channel_clusters "clusters"
  @channel_users_gossip "users_gossip"
  @channel_users_local "users_local"

  @user_timer_interval_ms 10_000 # check every x seconds
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
  @spec init(any) :: {:ok, %{ets_users: atom | :ets.tid(), ets_node_users:  atom | :ets.tid(), user_timer: reference}}
  def init(_map) do
    Process.flag(:trap_exit, true)

    ets_users = :ets.new(:users, [:set, :protected, :named_table])
    ets_node_users = :ets.new(:node_users, [:bag, :public, :named_table])
    user_timer = Process.send_after(self(), :tick, @user_timer_interval_ms)

    # handle 'nodeup' and 'nodedown' events
    :net_kernel.monitor_nodes(true)

    Phoenix.PubSub.subscribe(Notme.PubSub, @channel_users_gossip)

    Logger.info("user_tracker.init, subscribed to #{@channel_users_gossip}")

    {:ok, %{ets_users: ets_users, ets_node_users: ets_node_users, user_timer: user_timer}}
  end

  @impl true
  def handle_call(:users_list, _from, %{ets_users: _ets_users, ets_node_users: ets_node_users} = state) do
    {:reply, _ets_user_list(ets_node_users), state}
  end

  @impl true
  def handle_cast({:user_offline, user_handle}, %{ets_users: ets_users, ets_node_users: ets_node_users} = state) do
    :ets.delete(ets_users, user_handle)
    :ets.match_delete(ets_node_users, {Node.self(), user_handle})

    Logger.info("genserver 'user_tracker' msg 'user_offline' user_handle '#{user_handle}'")

    # broadcast user gossip message to peer nodes
    for node <- Node.list() do
      Phoenix.PubSub.direct_broadcast(
        node, Notme.PubSub, @channel_users_gossip, %{event: "users_sync", node: Node.self(), users: _ets_user_list(ets_node_users, Node.self())}
      )
    end

    Phoenix.PubSub.local_broadcast(
      Notme.PubSub, @channel_users_local, %{event: "users_online", node: Node.self(), users: _ets_user_list(ets_node_users)}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:user_online, user_handle, user_data}, %{ets_users: ets_users, ets_node_users: ets_node_users} = state) do
    Logger.info("genserver 'user_tracker' msg 'user_online' user_handle '#{user_handle}'")

    case :ets.lookup(ets_users, user_handle) do
      [] ->
        :ets.insert(ets_users, {user_handle, user_data})
        :ets.insert(ets_node_users, {Node.self(), user_handle})

        # broadcast user gossip message to peer nodes
        for node <- Node.list() do
          Phoenix.PubSub.direct_broadcast(
            node, Notme.PubSub, @channel_users_gossip, %{event: "users_sync", node: Node.self(), users: _ets_user_list(ets_node_users, Node.self())}
          )
        end

        Phoenix.PubSub.local_broadcast(
          Notme.PubSub, @channel_users_local, %{event: "users_online", node: Node.self(), users: _ets_user_list(ets_node_users)}
        )
      _ ->
        :ets.insert(ets_users, {user_handle, user_data})
        :ets.insert(ets_node_users, {Node.self(), user_handle})
    end

    {:noreply, state}
  end

  # users_local messages

  def handle_info({:nodedown, node}, %{ets_node_users: ets_node_users} = state) do
    Logger.info("genserver 'user_tracker' event 'nodedown' node '#{node}'")

    user_node_set_cur = MapSet.new(Map.keys(_ets_user_list(ets_node_users, node)))
    user_node_set_del = MapSet.difference(user_node_set_cur, MapSet.new())

    Logger.info("genserver 'user_tracker' user_node_set_del '#{inspect(user_node_set_del)}'")

    for user_handle <- Enum.to_list(user_node_set_del) do
      :ets.match_delete(:node_users, {node, user_handle})
    end

    # broadcast 'users_online message to local node

    Phoenix.PubSub.local_broadcast(
      Notme.PubSub, @channel_users_local, %{event: "users_online", node: Node.self(), users: _ets_user_list(ets_node_users)}
    )

    # broadcast 'nodes_sync' message

    nodes = Enum.sort([Node.self() | Node.list()])

    Phoenix.PubSub.broadcast(
      Notme.PubSub, @channel_clusters, %{event: "nodes_sync", nodes: nodes}
    )

    {:noreply, state}
  end

  def handle_info({:nodeup, node}, %{ets_node_users: ets_node_users} = state) do
    Logger.info("genserver 'user_tracker' event 'nodeup' node '#{node}'")

    if node != Node.self() do
      # send users_sync to new node
      Phoenix.PubSub.direct_broadcast(
        node, Notme.PubSub, @channel_users_gossip, %{event: "users_sync", node: Node.self(), users: _ets_user_list(ets_node_users, Node.self())}
      )
    end

    # broadcast 'nodes_sync' message

    nodes = Enum.sort([Node.self() | Node.list()])

    Phoenix.PubSub.broadcast(
      Notme.PubSub, @channel_clusters, %{event: "nodes_sync", nodes: nodes}
    )

    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{ets_users: ets_users, ets_node_users: ets_node_users} = state) do
    user_timer = Process.send_after(self(), :tick, @user_timer_interval_ms)

    users_list = :ets.match(ets_users, {:"$1", :"$2"})
    time_now = :os.system_time(:seconds)

    users_offline = Enum.filter(users_list, fn [_user_handle, user_map] ->
      time_now - Map.get(user_map, :online_at) > @user_offline_interval_sec
    end)

    if length(users_offline) > 0 do
      for [user_handle, _user_map] = _user_list <- users_offline do
        :ets.delete(ets_users, user_handle)
        :ets.match_delete(ets_node_users, {Node.self(), user_handle})
      end

      # broadcast user gossip message to peer nodes
      for node <- Node.list() do
        Phoenix.PubSub.direct_broadcast(
          node, Notme.PubSub, @channel_users_gossip, %{event: "users_sync", node: Node.self(), users: _ets_user_list(ets_node_users, Node.self())}
        )
      end

      # broadcast message to local node
      Phoenix.PubSub.local_broadcast(
        Notme.PubSub, @channel_users_local, %{event: "users_online", node: Node.self(), users: _ets_user_list(ets_node_users)}
      )
    end

    {:noreply, %{state | user_timer: user_timer}}
  end

  # users_gossip messages

  def handle_info(%{event: "users_sync", node: node, users: users} = _params, socket) do
    Logger.info("channel '#{@channel_users_gossip}' event 'users_sync' node '#{node}' users '#{Map.keys(users)}'")

    user_node_set_cur = MapSet.new(Map.keys(_ets_user_list(:node_users, node)))
    user_node_set_new = MapSet.new(Map.keys(users))
    user_node_set_add = MapSet.difference(user_node_set_new, user_node_set_cur)
    user_node_set_del = MapSet.difference(user_node_set_cur, user_node_set_new)

    for user_handle <- Enum.to_list(user_node_set_del) do
      :ets.match_delete(:node_users, {node, user_handle})
    end

    for user_handle <- Enum.to_list(user_node_set_add) do
      :ets.insert(:node_users, {node, user_handle})
    end

    Phoenix.PubSub.local_broadcast(
      Notme.PubSub, @channel_users_local, %{event: "users_online", node: Node.self(), users: _ets_user_list(:node_users)}
    )

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason,  _state) do
    Logger.info("genserver 'user_tracker' terminate")
  end

  # shared functions

  def _ets_user_list(ets_table, node_name) do
    Enum.reduce(:ets.match(ets_table, {node_name, :"$2"}), %{}, fn user_list, user_map ->
      [user_handle | _] = user_list

      Map.put(user_map, user_handle, %{})
    end)
  end


  @spec _ets_user_list(atom | :ets.tid()) :: map()
  def _ets_user_list(ets_table) do
    Enum.reduce(:ets.match(ets_table, {:_, :"$2"}), %{}, fn user_list, user_map ->
      [user_handle | _] = user_list

      Map.put(user_map, user_handle, %{})
    end)
  end

end
