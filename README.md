# CssLinter

A CSS linting and analysis tool with pluggable strategies for scanning and reporting on CSS class usage patterns.

## Features

- **Pluggable Strategies**: Analyze different CSS frameworks (Tailwind, Bootstrap, custom, etc.)
- **Detailed Reporting**: Get statistics on class usage, categorization, and patterns
- **JSON Export**: Export analysis results for aggregation and tracking over time
- **File Context**: See where classes are used with line numbers and context

## Installation

Add `css_linter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:css_linter, github: "vintrepid/css_linter", branch: "master"}
  ]
end
```

## Usage

### Analyze with Tailwind Strategy

```bash
mix css_linter.analyze --strategy tailwind
```

### Export to JSON

```bash
mix css_linter.analyze --strategy tailwind --output analysis.json
```

### Available Options

- `--strategy` - Analysis strategy to use (default: "tailwind")
- `--output` - Output file path for JSON export
- `--paths` - Comma-separated list of paths to scan (default: "lib")

## Strategies

### Tailwind

Categorizes Tailwind CSS classes into groups:
- Layout (flex, grid, display)
- Spacing (padding, margin, gap)
- Sizing (width, height)
- Typography (font, text)
- Colors (bg, text, border colors)
- Effects (shadow, opacity, blur)
- DaisyUI Components
- And more...

## Example Output

```
CSS Analysis Report
==================

Total Files Scanned: 45
Total Classes Found: 258 unique (1,191 occurrences)

Top 10 Classes:
  flex: 45 occurrences
  gap-4: 32 occurrences
  btn: 28 occurrences
  ...

By Category:
  layout: 156 occurrences (45 unique)
  spacing: 134 occurrences (38 unique)
  daisyui-component: 89 occurrences (12 unique)
  ...
```

## License

MIT

## Installation

See [INSTALLATION.md](INSTALLATION.md) for complete setup instructions.

Quick start:

```elixir
{:css_linter, github: "vintrepid/css_linter"}
```

Then:

```bash
mix deps.get
mix css_linter.analyze --strategy tailwind --output analysis.json
```

## UI Components

Web UI components (LiveViews for viewing analysis) are currently in development.

For now, see Maestro project for reference LiveView implementations:
- `TailwindAnalysisLive` - Analysis dashboard
- `PageInventoryLive` - HTML tag search across pages

These can be copied and adapted to your project.
