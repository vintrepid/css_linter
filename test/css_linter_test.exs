defmodule CssLinterTest do
  use ExUnit.Case
  doctest CssLinter

  test "analyzes Tailwind classes" do
    assert {:ok, results} = CssLinter.analyze(:tailwind, path: "lib/")
    assert is_map(results)
    assert Map.has_key?(results, :summary)
    assert Map.has_key?(results, :classes)
    assert is_list(results.classes)
  end
end
