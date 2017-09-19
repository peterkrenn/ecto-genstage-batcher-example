use Mix.Config

config :eb,
  ecto_repos: [EB.Repo]

config :eb, EB.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://localhost/eb"
