import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :chess, Chess.Repo,
  username: "postgres",
  password: "postgres",
  database: "chess_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chess, ChessWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "A95XNk3jBpR4Sg5cO92n2aViSXFgt9asmjQF1DjPG7zPfkTMGo1WSi5w2sxF8bG6",
  server: false

# In test we don't send emails.
config :chess, Chess.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Oath
config :oath, enable_contracts: true

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
