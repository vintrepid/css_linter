defmodule Mix.Tasks.CssLinter.Analyze do
  use Mix.Task

  @shortdoc "Analyzes CSS usage with the specified strategy"
  
  @moduledoc """
  Scans project files for CSS class usage based on the specified strategy.
  
  ## Usage
  
      mix css_linter.analyze --strategy tailwind
      mix css_linter.analyze --strategy tailwind --output analysis.json
      mix css_linter.analyze --strategy tailwind --output analysis.json --description "After refactor"
  
  ## Options
  
    * `--strategy` - Analysis strategy to use (default: tailwind)
    * `--output` - Path to write JSON results (optional)
    * `--description` - Description for this analysis run (optional)
    * `--path` - Base path to scan (default: lib/)
  """

  def run(args) do
    {opts, _, _} = OptionParser.parse(args,
      strict: [
        strategy: :string,
        output: :string,
        description: :string,
        path: :string
      ]
    )
    
    strategy = String.to_atom(opts[:strategy] || "tailwind")
    
    IO.puts("Scanning project for CSS classes using #{strategy} strategy...")
    
    analyze_opts = [
      output: opts[:output],
      description: opts[:description],
      path: opts[:path] || "lib/"
    ]
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    
    case CssLinter.analyze(strategy, analyze_opts) do
      {:ok, results} ->
        if opts[:output] do
          IO.puts("Results written to #{opts[:output]}")
        end
        
        CssLinter.Reporter.print_summary(results)
        
      {:error, reason} ->
        Mix.shell().error("Analysis failed: #{reason}")
        exit({:shutdown, 1})
    end
  end
end
