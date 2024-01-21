import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :notme, Notme.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres-dev",
  port: 5433,
  database: "phoenix_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :notme, NotmeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/xUn1KVnxGae4hkUn6xML7Tx2ynaC8CctwuC8gQHTQQwqxGJSsR4GOrM5HzlNhwq",
  server: false

# In test we don't send emails.
config :notme, Notme.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Opentelemetry

config :notme, :otel_exporter_uri, "http://opentelemetrycollector-dev:4318"
config :notme, :otel_service_name, "elixir-tst"

# Redpanda

config :notme, :redpanda_host, "redpanda-dev"
config :notme, :redpanda_port, 9092
config :notme, :redpanda_topics, ["elixir-tst"]
config :notme, :redpanda_group_default, "group-0"

config :notme, :redpanda_topic_inventory, "pipe-inventory-tst"
config :notme, :redpanda_topic_simple, "pipe-simple-tst"
