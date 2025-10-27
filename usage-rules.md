## Using CssLinter

CssLinter is a CSS analysis tool with pluggable strategies for scanning and reporting on CSS class usage patterns.
Consult the usage rules in `usage-rules/css_linter.md` for detailed guidelines.

## Available Tasks

### mix css_linter.analyze

Analyzes CSS class usage in your project.

```bash
# Analyze with Tailwind strategy
mix css_linter.analyze --strategy tailwind

# Export to JSON
mix css_linter.analyze --strategy tailwind --output analysis.json

# Scan specific paths
mix css_linter.analyze --paths "lib,priv/templates"
```

See `usage-rules/css_linter.md` for complete documentation including:
- Available strategies
- Custom strategy development
- Output formats
- Best practices
