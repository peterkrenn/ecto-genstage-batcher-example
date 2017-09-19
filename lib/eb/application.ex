defmodule EB.Application do
  use Application

  def start(_type, _args) do
    children = [
      EB.Repo,
      {Registry, keys: :unique, name: EB.Session.Registry},
      EB.Session.Supervisor,
      EB.Dispatcher,
      EB.User.Loader.Supervisor
    ]

    opts = [strategy: :one_for_one, name: EB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
