defmodule CssLinter.Schema.TailwindClassUsage do
  @moduledoc """
  Ecto schema for storing Tailwind CSS class usage analysis results.
  
  This schema can be used with any Ecto repo. The repo must be passed
  as an argument to query functions, or configured via application env:
  
      config :css_linter,
        repo: MyApp.Repo
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "css_class_usage" do
    field :class_name, :string
    field :category, :string
    field :file_path, :string
    field :line_number, :integer
    field :context, :string
    field :usage_count, :integer, default: 1
    field :analyzed_at, :utc_datetime
    field :description, :string
    field :project_name, :string

    timestamps()
  end

  def changeset(class_usage, attrs) do
    class_usage
    |> cast(attrs, [:class_name, :category, :file_path, :line_number, :context, :usage_count, :analyzed_at, :description, :project_name])
    |> validate_required([:class_name, :file_path, :line_number, :analyzed_at])
  end

  defp repo do
    Application.get_env(:css_linter, :repo) || 
      raise "css_linter repo not configured. Add to config: config :css_linter, repo: MyApp.Repo"
  end

  def available_projects(custom_repo \\ nil) do
    repo = custom_repo || repo()
    
    query = from c in __MODULE__,
      where: not is_nil(c.project_name),
      select: c.project_name,
      distinct: true,
      order_by: c.project_name

    repo.all(query)
  end

  def available_timestamps(custom_repo \\ nil) do
    repo = custom_repo || repo()
    
    query = from c in __MODULE__,
      where: not is_nil(c.analyzed_at),
      select: c.analyzed_at,
      distinct: true,
      order_by: [desc: c.analyzed_at]

    repo.all(query)
  end

  def analysis_summary(custom_repo \\ nil) do
    repo = custom_repo || repo()
    
    query = from c in __MODULE__,
      select: %{
        total_classes: fragment("COUNT(DISTINCT ?)", c.class_name),
        total_files: fragment("COUNT(DISTINCT ?)", c.file_path),
        total_usages: count(c.id)
      }

    repo.one(query)
  end

  def summary_stats(analyzed_at \\ nil, project_name \\ nil, custom_repo \\ nil) do
    repo = custom_repo || repo()
    
    query = from c in __MODULE__,
      group_by: c.class_name,
      select: %{
        class_name: c.class_name,
        category: fragment("array_agg(DISTINCT ?)", c.category),
        total_occurrences: count(c.id),
        file_count: fragment("COUNT(DISTINCT ?)", c.file_path)
      },
      order_by: [desc: count(c.id)]

    query = if analyzed_at, do: where(query, [c], c.analyzed_at == ^analyzed_at), else: query
    query = if project_name && project_name != "all", do: where(query, [c], c.project_name == ^project_name), else: query
    
    repo.all(query)
  end

  def class_details(class_name, analyzed_at \\ nil, project_name \\ nil, custom_repo \\ nil) do
    repo = custom_repo || repo()
    
    query = from c in __MODULE__,
      where: c.class_name == ^class_name,
      select: c,
      order_by: [c.file_path, c.line_number]

    query = if analyzed_at, do: where(query, [c], c.analyzed_at == ^analyzed_at), else: query
    query = if project_name && project_name != "all", do: where(query, [c], c.project_name == ^project_name), else: query
    
    repo.all(query)
  end

  def category_stats(analyzed_at \\ nil, project_name \\ nil, custom_repo \\ nil) do
    repo = custom_repo || repo()
    
    query = from c in __MODULE__,
      where: not is_nil(c.category),
      group_by: c.category,
      select: %{
        category: c.category,
        unique_classes: fragment("COUNT(DISTINCT ?)", c.class_name),
        total_usages: count(c.id)
      },
      order_by: [desc: count(c.id)]

    query = if analyzed_at, do: where(query, [c], c.analyzed_at == ^analyzed_at), else: query
    query = if project_name && project_name != "all", do: where(query, [c], c.project_name == ^project_name), else: query
    
    repo.all(query)
  end
end
