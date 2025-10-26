defmodule CssLinter do
  @moduledoc """
  CSS linting and analysis tool with pluggable strategies.
  """

  alias CssLinter.Scanner
  alias CssLinter.Reporter

  def analyze(strategy \\ :tailwind, opts \\ []) do
    strategy_module = strategy_module(strategy)
    
    with {:ok, files} <- Scanner.find_files(opts),
         {:ok, results} <- strategy_module.analyze(files, opts),
         :ok <- maybe_write_output(results, opts) do
      {:ok, results}
    end
  end

  defp strategy_module(:tailwind), do: CssLinter.Strategies.Tailwind
  defp strategy_module(module) when is_atom(module), do: module

  defp maybe_write_output(results, opts) do
    case Keyword.get(opts, :output) do
      nil -> :ok
      path -> Reporter.write_json(results, path)
    end
  end
end
