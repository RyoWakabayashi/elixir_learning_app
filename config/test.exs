import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :elixir_learning_app, ElixirLearningApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "elixir_learning_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_learning_app, ElixirLearningAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/VssKDYJDCL0x/aUKhMl9gTocvlbIBg+GSAktu6F1dd0KPcWRdrSvqCbvkRi/SDy",
  server: true

# In test we don't send emails
config :elixir_learning_app, ElixirLearningApp.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix_test, :endpoint, ElixirLearningAppWeb.Endpoint

config :phoenix_test,
  otp_app: :my_app,
  playwright: [
    cli: "assets/node_modules/playwright/cli.js",
    browser: :chromium,
    headless: false,
    trace: true,
    trace_dir: "tmp"
  ],
  timeout_ms: 2000
