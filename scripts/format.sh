#!/bin/bash
# format.sh - Quick code formatting
# Usage: ./scripts/format.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "🔧 Formatting Python code..."

# Format with black
if command -v black &> /dev/null; then
    black src/ --line-length 100
    echo "✓ Formatted with black"
else
    echo "⚠️  black not installed: pip install black"
fi

# Lint with ruff
if command -v ruff &> /dev/null; then
    ruff check src/ --fix
    echo "✓ Linted with ruff"
else
    echo "⚠️  ruff not installed: pip install ruff"
fi

echo ""
echo "✨ Done! Review changes with: git diff"
