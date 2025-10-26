defmodule CssLinter.Reporter do
  @moduledoc """
  Handles output formatting and file writing for analysis results.
  """

  def write_json(results, path) do
    case Jason.encode(results, pretty: true) do
      {:ok, json} ->
        File.write!(path, json)
        :ok
      
      {:error, reason} ->
        {:error, "Failed to encode JSON: #{inspect(reason)}"}
    end
  end

  def print_summary(results) do
    summary = results.summary
    
    IO.puts("\n=== Summary ===")
    IO.puts("Unique classes: #{summary.unique_classes}")
    IO.puts("Total occurrences: #{summary.total_occurrences}")
    
    IO.puts("\n=== Top 20 Most Used Classes ===")
    results.classes
    |> Enum.take(20)
    |> Enum.each(fn %{class_name: name, count: count, category: cat} ->
      IO.puts("#{String.pad_trailing(name, 30)} #{count} times (#{cat})")
    end)
    
    IO.puts("\n=== By Category ===")
    results.classes
    |> Enum.group_by(& &1.category)
    |> Enum.map(fn {category, classes} ->
      {category, length(classes), Enum.sum(Enum.map(classes, & &1.count))}
    end)
    |> Enum.sort_by(fn {_cat, _unique, total} -> total end, :desc)
    |> Enum.each(fn {category, unique_count, total_count} ->
      IO.puts("#{String.pad_trailing(category, 20)} #{unique_count} unique, #{total_count} total")
    end)
  end
end
