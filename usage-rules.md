## Using CssLinter

CssLinter is a CSS analysis tool with pluggable strategies for scanning and reporting on CSS class usage patterns.

## Quick Start

```bash
# Analyze with Tailwind strategy
mix css_linter.analyze --strategy tailwind

# Export to JSON
mix css_linter.analyze --strategy tailwind --output analysis.json
```

For detailed usage guidelines, see `usage-rules/usage.md`.
