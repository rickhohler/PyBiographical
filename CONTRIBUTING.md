# Contributing to PyBiographical

Thank you for your interest in contributing to PyBiographical!

## Development Setup

```bash
# Clone the repository
git clone https://github.com/rickhohler/PyBiographical.git
cd PyBiographical

# Install in editable mode with dev dependencies
pip install -e .[dev]
```

## Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=pybiographical --cov-report=html
```

## Code Style

We use standard Python code formatting tools:

```bash
# Format code
black src/

# Check code style
ruff check src/
```

## Publishing to PyPI

### Prerequisites

1. Install build tools:
   ```bash
   pip install build twine
   ```

2. Configure PyPI credentials in `~/.pypirc` or use environment variables

### Build and Publish

```bash
# Update version in pyproject.toml and CHANGELOG.md

# Clean previous builds
rm -rf dist/ build/

# Build distribution packages
python -m build

# Check the distribution
twine check dist/*

# Upload to TestPyPI (optional)
twine upload --repository testpypi dist/*

# Upload to PyPI
twine upload dist/*
```

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backwards compatible manner
- **PATCH** version for backwards compatible bug fixes

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Update documentation as needed
7. Commit your changes (`git commit -m 'Add some amazing feature'`)
8. Push to your branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
