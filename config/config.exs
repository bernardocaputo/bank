# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bank,
  ecto_repos: [Bank.Repo]

# Configures the endpoint
config :bank, BankWeb.Endpoint,
  url: [host: "localhost"],
  server: true,
  secret_key_base: "2J+Ts/AFYDWEohndl7NPpRuV047edkrXL2zKa9KFfAG3D10LCPxhv4c/6S7l3qbJ",
  render_errors: [view: BankWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Bank.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :phoenix, :json_library, Jason

config :guardian, Guardian,
  issuer: "bank",
  ttl: {1, :days},
  allowed_drift: 30000,
  secret_key:
    "Jy07+9sloWXqJBVMeUt+GazJy07+9sloWXqJBVSOQ+73XqeG5K2oTOKT1aPDKANEYwCpKQocow+XPjWMeUt+Gaz",
  serializer: Bank.Auth.GuardianSerializer
