defmodule CssLinter.Strategies.Tailwind do
  @moduledoc """
  Tailwind CSS and DaisyUI analysis strategy.
  
  Scans files for Tailwind/DaisyUI classes and provides:
  - Class categorization (typography, spacing, components, etc.)
  - Usage statistics
  - File and line location tracking
  """

  @behaviour CssLinter.Strategy

  alias CssLinter.Scanner

  @impl true
  def analyze(files, opts \\ []) do
    description = Keyword.get(opts, :description)
    analyzed_at = DateTime.utc_now() |> DateTime.truncate(:second)
    
    class_data =
      files
      |> Enum.flat_map(&extract_classes_from_file/1)
      |> Enum.group_by(& &1.class_name)
      |> Enum.map(fn {class_name, occurrences} ->
        %{
          class_name: class_name,
          count: length(occurrences),
          category: categorize_class(class_name),
          occurrences: occurrences
        }
      end)
      |> Enum.sort_by(& &1.count, :desc)
    
    summary = %{
      unique_classes: length(class_data),
      total_occurrences: Enum.sum(Enum.map(class_data, & &1.count))
    }
    
    result = %{
      analyzed_at: analyzed_at,
      description: description,
      summary: summary,
      classes: class_data
    }
    
    {:ok, result}
  end

  defp extract_classes_from_file(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.with_index(1)
        |> Enum.flat_map(fn {line, line_number} ->
          extract_classes_from_line(line, file_path, line_number)
        end)
      
      {:error, _} -> []
    end
  end

  defp extract_classes_from_line(line, file_path, line_number) do
    class_regex = ~r/class[=:]\s*["{]([^"}]+)["}]/
    
    case Regex.run(class_regex, line, capture: :all_but_first) do
      [class_string] ->
        class_string
        |> clean_class_string()
        |> String.split(~r/\s+/)
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(fn class_name ->
          %{
            class_name: class_name,
            file_path: file_path,
            line_number: line_number,
            context: String.trim(line)
          }
        end)
      
      nil ->
        []
    end
  end

  defp clean_class_string(str) do
    str
    |> String.replace(~r/#\{[^}]+\}/, "")
    |> String.replace(~r/\[|\]/, "")
    |> String.replace(",", " ")
    |> String.replace("&&", "")
    |> String.replace("||", "")
  end

  defp categorize_class(class_name) do
    cond do
      String.starts_with?(class_name, "text-") -> "typography"
      String.starts_with?(class_name, "font-") -> "typography"
      String.starts_with?(class_name, "leading-") -> "typography"
      
      class_name in ~w(flex grid block inline inline-block hidden) -> "display"
      String.starts_with?(class_name, "flex-") -> "flexbox"
      String.starts_with?(class_name, "grid-") -> "grid"
      String.starts_with?(class_name, "items-") -> "flexbox"
      String.starts_with?(class_name, "justify-") -> "flexbox"
      
      String.starts_with?(class_name, "w-") -> "sizing"
      String.starts_with?(class_name, "h-") -> "sizing"
      String.starts_with?(class_name, "size-") -> "sizing"
      String.starts_with?(class_name, "max-") -> "sizing"
      String.starts_with?(class_name, "min-") -> "sizing"
      
      class_name in ~w(p-0 p-1 p-2 p-3 p-4 p-5 p-6 p-8 p-10 p-12) or
      String.starts_with?(class_name, "p-") or
      String.starts_with?(class_name, "m-") or
      String.starts_with?(class_name, "px-") or
      String.starts_with?(class_name, "py-") or
      String.starts_with?(class_name, "pt-") or
      String.starts_with?(class_name, "pb-") or
      String.starts_with?(class_name, "pl-") or
      String.starts_with?(class_name, "pr-") or
      String.starts_with?(class_name, "mx-") or
      String.starts_with?(class_name, "my-") or
      String.starts_with?(class_name, "mt-") or
      String.starts_with?(class_name, "mb-") or
      String.starts_with?(class_name, "ml-") or
      String.starts_with?(class_name, "mr-") or
      String.starts_with?(class_name, "gap-") or
      String.starts_with?(class_name, "space-") -> "spacing"
      
      String.starts_with?(class_name, "bg-") -> "background"
      String.starts_with?(class_name, "border-") -> "borders"
      String.starts_with?(class_name, "rounded-") -> "borders"
      class_name in ~w(rounded border) -> "borders"
      
      String.starts_with?(class_name, "shadow-") -> "effects"
      class_name == "shadow" -> "effects"
      String.starts_with?(class_name, "opacity-") -> "effects"
      String.starts_with?(class_name, "transition-") -> "effects"
      
      String.starts_with?(class_name, "absolute") -> "position"
      String.starts_with?(class_name, "relative") -> "position"
      String.starts_with?(class_name, "fixed") -> "position"
      String.starts_with?(class_name, "sticky") -> "position"
      String.starts_with?(class_name, "top-") -> "position"
      String.starts_with?(class_name, "bottom-") -> "position"
      String.starts_with?(class_name, "left-") -> "position"
      String.starts_with?(class_name, "right-") -> "position"
      String.starts_with?(class_name, "z-") -> "position"
      
      String.starts_with?(class_name, "btn") -> "daisyui-component"
      String.starts_with?(class_name, "card") -> "daisyui-component"
      String.starts_with?(class_name, "badge") -> "daisyui-component"
      String.starts_with?(class_name, "alert") -> "daisyui-component"
      String.starts_with?(class_name, "navbar") -> "daisyui-component"
      String.starts_with?(class_name, "menu") -> "daisyui-component"
      String.starts_with?(class_name, "dropdown") -> "daisyui-component"
      String.starts_with?(class_name, "modal") -> "daisyui-component"
      String.starts_with?(class_name, "toast") -> "daisyui-component"
      String.starts_with?(class_name, "table") -> "daisyui-component"
      String.starts_with?(class_name, "input") -> "daisyui-component"
      String.starts_with?(class_name, "select") -> "daisyui-component"
      String.starts_with?(class_name, "textarea") -> "daisyui-component"
      String.starts_with?(class_name, "checkbox") -> "daisyui-component"
      String.starts_with?(class_name, "radio") -> "daisyui-component"
      String.starts_with?(class_name, "toggle") -> "daisyui-component"
      String.starts_with?(class_name, "link") -> "daisyui-component"
      class_name in ~w(label fieldset list) -> "daisyui-component"
      
      String.contains?(class_name, "primary") -> "daisyui-theme"
      String.contains?(class_name, "secondary") -> "daisyui-theme"
      String.contains?(class_name, "accent") -> "daisyui-theme"
      String.contains?(class_name, "neutral") -> "daisyui-theme"
      String.contains?(class_name, "base-") -> "daisyui-theme"
      String.contains?(class_name, "info") -> "daisyui-theme"
      String.contains?(class_name, "success") -> "daisyui-theme"
      String.contains?(class_name, "warning") -> "daisyui-theme"
      String.contains?(class_name, "error") -> "daisyui-theme"
      
      String.starts_with?(class_name, "hover:") -> "interactive-state"
      String.starts_with?(class_name, "focus:") -> "interactive-state"
      String.starts_with?(class_name, "active:") -> "interactive-state"
      
      String.starts_with?(class_name, "sm:") -> "responsive"
      String.starts_with?(class_name, "md:") -> "responsive"
      String.starts_with?(class_name, "lg:") -> "responsive"
      String.starts_with?(class_name, "xl:") -> "responsive"
      
      true -> "other"
    end
  end
end
