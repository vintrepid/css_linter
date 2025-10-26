defmodule CssLinter.Scanner do
  @moduledoc """
  File scanning utilities for finding and reading project files.
  """

  def find_files(opts \\ []) do
    path = Keyword.get(opts, :path, "lib/")
    patterns = Keyword.get(opts, :file_patterns, ["**/*.{ex,heex}"])
    exclude = Keyword.get(opts, :exclude_patterns, ["deps/**", "_build/**"])
    
    files =
      patterns
      |> Enum.flat_map(fn pattern ->
        Path.join(path, pattern)
        |> Path.wildcard()
      end)
      |> Enum.reject(fn file ->
        Enum.any?(exclude, &matches_pattern?(file, &1))
      end)
      |> Enum.uniq()
    
    {:ok, files}
  end

  def read_file(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, "Failed to read #{path}: #{reason}"}
    end
  end

  def extract_lines(content) do
    content
    |> String.split("\n")
    |> Enum.with_index(1)
  end

  defp matches_pattern?(file, pattern) do
    regex = pattern
    |> String.replace("**", ".*")
    |> String.replace("*", "[^/]*")
    |> Regex.compile!()
    
    Regex.match?(regex, file)
  end
end
