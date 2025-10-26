defmodule CssLinter.Strategy do
  @moduledoc """
  Behaviour for CSS analysis strategies.
  
  Each strategy implements different CSS linting/analysis rules.
  """

  @callback analyze(files :: [String.t()], opts :: keyword()) :: {:ok, map()} | {:error, String.t()}
end
