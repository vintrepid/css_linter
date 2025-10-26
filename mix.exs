defmodule CssLinter.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/vintrepid/css_linter"

  def project do
    [
      app: :css_linter,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "CSS linting and analysis tool with pluggable strategies",
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
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Vince"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
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
