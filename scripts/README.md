# Development Scripts

Helper scripts for PyBiographical development and release management.

## Available Scripts

### `format.sh` - Quick Code Formatting

Formats all Python code with `black` and lints with `ruff`.

**Usage:**
```bash
./scripts/format.sh
```

**Requirements:**
```bash
pip install black ruff
```

---

### `prepare-release.sh` - Release Preparation

Comprehensive script that:
- Formats Python code
- Lints code
- Bumps version (patch/minor/major)
- Updates CHANGELOG.md
- Shows git status and next steps

**Usage:**
```bash
# Interactive mode (prompts for version type)
./scripts/prepare-release.sh

# Direct usage
./scripts/prepare-release.sh patch   # 0.2.0 → 0.2.1
./scripts/prepare-release.sh minor   # 0.2.0 → 0.3.0
./scripts/prepare-release.sh major   # 0.2.0 → 1.0.0
```

**What it does:**
1. ✅ Checks for uncommitted changes
2. 📝 Formats code with `black`
3. 🔍 Lints code with `ruff --fix`
4. 🔢 Bumps version in `pyproject.toml`
5. 📋 Updates `CHANGELOG.md` with new version
6. 📊 Shows git status
7. 💡 Provides next steps for commit and push

**Example workflow:**
```bash
# Format and prepare patch release
./scripts/prepare-release.sh patch

# Review changes
git diff

# Edit CHANGELOG.md if needed
vim CHANGELOG.md

# Commit and tag
git add -A
git commit -m "chore: release v0.2.1"
git tag v0.2.1

# Push (triggers CI/CD and PyPI publishing)
git push origin main
git push origin v0.2.1
```

---

## Quick Reference

```bash
# Just format code
./scripts/format.sh

# Format + prepare patch release
./scripts/prepare-release.sh patch

# Format + prepare minor release  
./scripts/prepare-release.sh minor

# Format + prepare major release
./scripts/prepare-release.sh major
```

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **patch** (0.2.0 → 0.2.1): Bug fixes, backwards compatible
- **minor** (0.2.0 → 0.3.0): New features, backwards compatible
- **major** (0.2.0 → 1.0.0): Breaking changes, incompatible API changes
