# CSS Linter Installation Guide

## Quick Start

Add to your `mix.exs`:

```elixir
def deps do
  [
    {:css_linter, github: "vintrepid/css_linter", branch: "main"}
  ]
end
```

Then run:

```bash
mix deps.get
mix css_linter.install
```

## What Gets Installed

The installer will:

1. Create database migration for `css_class_usage` table
2. Add routes for analysis UI (optional)
3. Configure required dependencies

## Manual Installation

If you prefer manual setup:

### 1. Add Dependencies

The package requires:
- `ecto_sql` - for database storage
- `phoenix_live_view` - for UI components

### 2. Create Migration

```bash
mix ecto.gen.migration create_css_class_usage
```

```elixir
defmodule YourApp.Repo.Migrations.CreateCssClassUsage do
  use Ecto.Migration

  def change do
    create table(:css_class_usage, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :class_name, :string, null: false
      add :category, :string
      add :file_path, :string, null: false
      add :line_number, :integer, null: false
      add :context, :text
      add :usage_count, :integer, default: 1
      add :analyzed_at, :utc_datetime, null: false
      add :description, :string
      add :project_name, :string

      timestamps()
    end

    create index(:css_class_usage, [:analyzed_at])
    create index(:css_class_usage, [:class_name])
    create index(:css_class_usage, [:project_name])
  end
end
```

### 3. Add Routes (Optional)

If you want the web UI:

```elixir
# router.ex
scope "/admin" do
  pipe_through :browser
  
  live "/css-analysis", CssLinter.Live.AnalysisLive
  live "/page-inventory", CssLinter.Live.PageInventoryLive
end
```

## Usage

### Running Analysis

```bash
# Analyze with Tailwind strategy
mix css_linter.analyze --strategy tailwind

# Save to database
mix css_linter.analyze --strategy tailwind --save-db

# Export to JSON
mix css_linter.analyze --strategy tailwind --output analysis.json
```

### Viewing Results

Navigate to `/admin/css-analysis` to see:
- Analysis history with timestamps
- Top used classes
- Class categorization
- File-by-file breakdown
- Multi-project comparison

### Page Inventory

Navigate to `/admin/page-inventory` to:
- Search for HTML tags across all pages
- See line numbers and content
- Identify repeated patterns for extraction

## Configuration

```elixir
# config/config.exs
config :css_linter,
  repo: YourApp.Repo,
  default_strategy: :tailwind,
  scan_paths: ["lib"]
```

## Extracting Patterns

The tool helps identify CSS patterns to extract:

### 1. Find Repeated Classes

Use the analysis page to find classes used 10+ times across multiple files.

### 2. Check Page Inventory

Search for tags like `h1`, `button`, `form` to see styling patterns.

### 3. Extract to Global CSS

For typography and base elements:

```css
/* app.css */
h1 {
  @apply text-2xl font-bold mb-4;
}
```

### 4. Extract to Components

For repeated UI patterns:

```elixir
# components/ui.ex
def card(assigns) do
  ~H"""
  <div class="card bg-base-100 shadow-xl">
    <%= render_slot(@inner_block) %>
  </div>
  """
end
```

## Future Extraction

When this package grows too large, consider splitting:

- `css_linter` - Core analysis engine
- `css_linter_phoenix` - Phoenix/LiveView UI
- `css_linter_tailwind` - Tailwind-specific strategies

For now, everything is in one package for simplicity.

## Troubleshooting

### Migration Fails

Ensure your Repo is configured and database exists:

```bash
mix ecto.create
mix ecto.migrate
```

### UI Not Loading

Check that Phoenix LiveView is properly configured in your endpoint.

### Analysis Returns Empty

Verify the scan paths in your config match your project structure.
