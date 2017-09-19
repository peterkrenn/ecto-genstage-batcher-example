defmodule EB.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eb,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EB.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:gen_stage, "~> 0.12"},
      {:postgrex, "~> 0.13"}
    ]
  end
end
