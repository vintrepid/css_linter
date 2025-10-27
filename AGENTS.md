# CssLinter Agent Guidelines

## Overview

CssLinter is a CSS analysis tool with pluggable strategies for scanning and reporting on CSS class usage patterns.

## Usage

### Installation

Add to your project's mix.exs:

```elixir
def deps do
  [
    {:css_linter, github: "vintrepid/css_linter", only: [:dev]}
  ]
end
```

### Available Tasks

#### `mix css_linter.analyze`

Analyzes CSS class usage in your project.

**Options:**
- `--strategy` - Analysis strategy to use (default: "tailwind")
- `--output` - Output file path for JSON export
- `--paths` - Comma-separated list of paths to scan (default: "lib")

**Examples:**
```bash
# Analyze with Tailwind strategy
mix css_linter.analyze --strategy tailwind

# Export to JSON
mix css_linter.analyze --strategy tailwind --output analysis.json

# Scan specific paths
mix css_linter.analyze --paths "lib,priv/templates"
```

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

### Custom Strategies

Create your own strategy by implementing the `CssLinter.Strategy` behavior:

```elixir
defmodule MyApp.CustomStrategy do
  @behaviour CssLinter.Strategy

  def categorize(class_name) do
    # Return category atom or nil
  end
  
  def category_name(category) do
    # Return human-readable category name
  end
end
```

## Development

### Structure

```
css_linter/
├── lib/
│   ├── css_linter/
│   │   ├── application.ex
│   │   ├── reporter.ex
│   │   ├── scanner.ex
│   │   ├── strategy.ex
│   │   ├── strategies/
│   │   │   └── tailwind.ex
│   │   └── schema/
│   ├── mix/
│   │   └── tasks/
│   │       └── css_linter.analyze.ex
│   └── css_linter.ex
├── test/
├── mix.exs
├── README.md
├── INSTALLATION.md
├── CHANGELOG.md
└── AGENTS.md (this file)
```

### Adding New Strategies

1. Create new file in `lib/css_linter/strategies/`
2. Implement `CssLinter.Strategy` behavior
3. Define `categorize/1` and `category_name/1` functions
4. Register in strategy loader

### Testing

```bash
mix test
```

### Release Process

1. Update CHANGELOG.md
2. Bump version in mix.exs
3. Commit changes
4. Tag release: `git tag v0.X.0`
5. Push: `git push --tags`

## Output Format

### Console Report

```
CSS Analysis Report
==================

Total Files Scanned: 45
Total Classes Found: 258 unique (1,191 occurrences)

Top 10 Classes:
  flex: 45 occurrences
  gap-4: 32 occurrences
  btn: 28 occurrences

By Category:
  layout: 156 occurrences (45 unique)
  spacing: 134 occurrences (38 unique)
```

### JSON Export

```json
{
  "summary": {
    "total_files": 45,
    "total_classes": 258,
    "total_occurrences": 1191
  },
  "classes": [
    {
      "name": "flex",
      "category": "layout",
      "count": 45,
      "files": [...]
    }
  ]
}
```

## Best Practices

- Run analysis regularly to track CSS usage trends
- Export JSON for historical tracking
- Use with Tailwind purge configuration
- Create custom strategies for project-specific patterns

## Related Documentation

- [README.md](README.md) - User-facing documentation
- [INSTALLATION.md](INSTALLATION.md) - Installation guide
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [TOOLS.md](https://github.com/vintrepid/agents/blob/main/TOOLS.md) - Creating tools guide
