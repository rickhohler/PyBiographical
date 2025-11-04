# Release Process

This document describes how to release a new version of PyBiographical to PyPI.

## Prerequisites

1. **GitHub Repository Settings:**
   - Go to Settings → Environments
   - Create two environments:
     - `testpypi` - for Test PyPI releases
     - `pypi` - for production PyPI releases
   - (Optional) Add required reviewers for the `pypi` environment

2. **PyPI Trusted Publishing Setup:**
   - Go to [PyPI](https://pypi.org) → Account Settings → Publishing
   - Add a "pending publisher" for:
     - **PyPI Project Name:** `pybiographical`
     - **Owner:** `username`
     - **Repository:** `PyBiographical`
     - **Workflow:** `test.yml`
     - **Environment:** `pypi`
   
   - Repeat for [TestPyPI](https://test.pypi.org) with environment `testpypi`

## Release Workflow

### 1. Update Version and Changelog

```bash
# Update version in pyproject.toml
vim pyproject.toml

# Update CHANGELOG.md
vim CHANGELOG.md
# Move items from [Unreleased] to new version section
```

### 2. Commit and Tag

```bash
# Commit changes
git add pyproject.toml CHANGELOG.md
git commit -m "chore: bump version to v0.2.1"

# Create and push tag
git tag v0.2.1
git push origin main
git push origin v0.2.1
```

### 3. Automated Publishing

The GitHub Actions workflow will automatically:

1. **Run Tests** - All test suites must pass
2. **Build Package** - Create wheel and source distribution
3. **Validate** - Check distribution with `twine check`
4. **Publish to TestPyPI** - Test the release first
5. **Publish to PyPI** - Final production release

### 4. Verify Release

After the workflow completes:

```bash
# Test installation from PyPI
pip install --upgrade pybiographical

# Verify version
python -c "import pybiographical; print(pybiographical.__version__)"
```

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (v1.0.0): Breaking changes, incompatible API changes
- **MINOR** (v0.2.0): New features, backwards compatible
- **PATCH** (v0.2.1): Bug fixes, backwards compatible

## Manual Release (Fallback)

If automated release fails, you can publish manually:

```bash
# Install tools
pip install build twine

# Build
python -m build

# Check
twine check dist/*

# Upload to TestPyPI (optional)
twine upload --repository testpypi dist/*

# Upload to PyPI
twine upload dist/*
```

## Troubleshooting

### Workflow doesn't trigger
- Ensure tag starts with 'v' (e.g., `v0.2.1`)
- Check that tag was pushed: `git push origin v0.2.1`

### Publishing fails
- Verify GitHub environment names match workflow
- Check PyPI trusted publisher configuration
- Ensure repository has `id-token: write` permissions

### Version already exists
- PyPI doesn't allow re-uploading the same version
- Increment version and create a new release
- Delete the failed tag: `git tag -d v0.2.1 && git push --delete origin v0.2.1`

## Post-Release

1. Create GitHub Release from tag
2. Update documentation if needed
3. Announce release in appropriate channels
