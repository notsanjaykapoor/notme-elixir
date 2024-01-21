defmodule Notme.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = OpentelemetryPhoenix.setup()

    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Telemetry supervisor
      NotmeWeb.Telemetry,
      # Start the Ecto repository
      Notme.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Notme.PubSub},
      # Start Finch
      {Finch, name: Notme.Finch},
      # Start presence after pubsub and before endpoint
      NotmeWebApp.Presence,
      # Start the Endpoint (http/https)
      NotmeWeb.Endpoint,
      # Start a worker by calling: Notme.Worker.start_link(arg)
      NotmeWeb.UserTracker,
      # {Notme.Worker, arg}
      # Clustering setup
      {Cluster.Supervisor, [topologies, [name: Notme.ClusterSupervisor]]}
    ]

    children = _config_pipelines(children)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Notme.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NotmeWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def _config_pipelines(children) do
    case String.to_integer(System.get_env("PIPELINES") || "0") do
      1 ->
        children ++ [Notme.Pipeline.Inventory, Notme.Pipeline.Simple]
      _ ->
        children
    end
  end
end
