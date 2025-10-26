defmodule CssLinter.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/vintrepid/css_linter"

  def project do
    [
      app: :css_linter,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "CSS linting and analysis tool with Phoenix LiveView UI",
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {CssLinter.Application, []}
    ]
  end

  defp deps do
    [
      {:igniter, "~> 0.6"},
      {:jason, "~> 1.4"},
      {:ecto_sql, "~> 3.12"},
      {:phoenix_live_view, "~> 1.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Vince"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: ~w(lib priv .formatter.exs mix.exs README.md LICENSE.md CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
