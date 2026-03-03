defmodule Colliders.MixProject do
  use Mix.Project

  @source_url "https://github.com/monoflow-ayvu/colliders"
  @version "0.1.3"

  def project do
    [
      app: :colliders,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      package: package(),
      description: "An Elixir library for detecting whether a bbox overlaps a polygon.",
      organization: "monoflow"
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:geo, "~> 4.1"},
      {:geo_turf, "~> 0.3.1"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "credo suggest --strict --all"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "Colliders",
      suorce_ref: "v#{@version}",
      source_url: @source_url,
      extras: extras()
    ]
  end

  defp extras do
    [
      "README.md": [
        title: "Readme"
      ]
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintaners: ["Vinicius Costa", "Fernando Mumbach"]
    }
  end
end
