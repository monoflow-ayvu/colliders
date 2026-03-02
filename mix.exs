defmodule Colliders.MixProject do
  use Mix.Project

  def project do
    [
      app: :colliders,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:geo, "~> 4.1"},
      {:geo_turf, "~> 0.3.1"}
    ]
  end
end
