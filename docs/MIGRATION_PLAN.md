# PyBiographical Library Migration Plan

## Overview

This document outlines the migration plan for extracting reusable components from the `metadata` project into the `PyBiographical` shared library. This will enable code reuse across biographical, metadata, and media-tagging projects.

**Version:** 0.2.0  
**Date:** November 2025  
**Author:** Jane Smith

---

## Goals

1. **Extract reusable components** from metadata project scripts
2. **Create well-structured library modules** with clear APIs
3. **Maintain backward compatibility** for existing scripts
4. **Improve testability** through separation of concerns
5. **Enable code reuse** across multiple projects

---

## Project Structure

### Current State
```
PyBiographical/
├── src/
│   └── PyBiographical/
│       ├── __init__.py
│       └── ramdisk_util.py  # v0.1.0
└── pyproject.toml
```

### Target State (v0.2.0)
```
PyBiographical/
├── src/
│   └── PyBiographical/
│       ├── __init__.py
│       ├── ramdisk_util.py
│       ├── persons/              # Person metadata management
│       │   ├── __init__.py
│       │   ├── models.py         # Data models (PersonFile, ValidationIssue, etc.)
│       │   ├── validation.py    # Person metadata validation
│       │   └── crud.py          # Person CRUD operations
│       ├── artifacts/            # Artifact metadata (for media-tagging)
│       │   └── __init__.py
│       ├── locations/            # Location metadata
│       │   └── __init__.py
│       ├── matching/             # Fuzzy matching utilities
│       │   ├── __init__.py
│       │   └── fuzzy.py         # Name/location fuzzy matching
│       └── io/
│           ├── __init__.py
│           └── yaml_utils.py    # YAML handling utilities
├── tests/
│   ├── __init__.py
│   ├── test_validation.py
│   ├── test_crud.py
│   ├── test_fuzzy.py
│   └── test_yaml_utils.py
├── docs/
│   ├── MIGRATION_PLAN.md (this file)
│   ├── API.md
│   └── EXAMPLES.md
└── pyproject.toml
```

---

## Component Extraction Plan

### 1. Person Validation Module (`PyBiographical.persons.validation`)

**Source:** `metadata/scripts/validate_person_yaml.py`

**Extract:**
- `ValidationIssue` class (severity levels, fixability tracking)
- `validate_yaml_file()` function
- `validate_person_data()` function
- `fix_file()` function
- Schema version constants

**API Design:**
```python
from pybiographical.persons.validation import (
    ValidationIssue,
    validate_person_yaml,
    validate_person_data,
    fix_schema_version
)

# Validate a person metadata YAML file
data, issues = validate_person_yaml(file_path)

# Validate in-memory person data
errors = validate_person_data(data_dict)

# Fix schema version issues
success = fix_schema_version(file_path, target_version='1.0.0')
```

**Dependencies:**
- `ruamel.yaml` (required)
- `pathlib` (stdlib)

---

### 2. Person CRUD Operations Module (`PyBiographical.persons.crud`)

**Source:** `metadata/scripts/person_crud.py`

**Extract:**
- `PersonCRUD` class (complete)
- Utility functions:
  - `compute_checksum()`
  - `create_backup()`
  - `generate_person_id()`
  - `sanitize_filename()`
  - `validate_person_data()`

**API Design:**
```python
from pybiographical.persons.crud import PersonCRUD, generate_person_id

# Initialize CRUD handler
crud = PersonCRUD(
    persons_dir='/path/to/persons',
    backup_dir='/path/to/backups',
    archive_dir='/path/to/archive'
)

# Create person (idempotent - checks for duplicates)
person = crud.create(
    given_names="John",
    surname="Doe",
    birth_year=1850,
    check_duplicates=True
)

# Read person
person = crud.read(person_id="I382302780374")

# Search with fuzzy matching
results = crud.search(surname="Johnson", birth_year=1825, fuzzy=True)

# Update person (idempotent - only updates if different)
success = crud.update(
    person_id="I382302780374",
    updates={'vital_events.birth.date': '1850-01-15'}
)

# Delete/archive person
success = crud.delete(person_id="I382302780374", archive=True)

# Restore from backup
success = crud.restore(person_id="I382302780374")
```

**Dependencies:**
- `ruamel.yaml` (required)
- `rapidfuzz` (optional - for fuzzy matching)
- `pathlib`, `hashlib`, `shutil` (stdlib)

---

### 3. Fuzzy Matching Module (`PyBiographical.matching.fuzzy`)

**Source:** `metadata/scripts/scrub_person_data.py` and `person_crud.py`

**Extract:**
- Name normalization functions
- Location normalization functions
- Fuzzy matching with configurable thresholds
- Confidence scoring algorithms

**API Design:**
```python
from pybiographical.matching.fuzzy import (
    normalize_name,
    normalize_location,
    fuzzy_match_name,
    fuzzy_match_location,
    compute_confidence_score
)

# Normalize names for matching
name1 = normalize_name("Johann Wolfgang von Goethe Jr.")
name2 = normalize_name("Johann Goethe")

# Fuzzy match names with confidence score
score = fuzzy_match_name(name1, name2, threshold=80)

# Normalize and match locations
loc1 = normalize_location("Harvey, Wells County, North Dakota, USA")
loc2 = normalize_location("Harvey, ND")
score = fuzzy_match_location(loc1, loc2)

# Multi-factor confidence scoring
confidence = compute_confidence_score(
    name_score=95,
    birth_year_diff=2,
    parent_match=True,
    location_score=85
)
```

**Dependencies:**
- `rapidfuzz` (required)
- `re` (stdlib)

---

### 4. YAML Utilities Module (`PyBiographical.io.yaml_utils`)

**Source:** Common patterns from all metadata scripts

**Extract:**
- Pre-configured YAML handler (ruamel.yaml settings)
- Safe YAML loading/dumping functions
- Backup creation utilities
- File checksum computation
- Atomic file operations

**API Design:**
```python
from pybiographical.io.yaml_utils import (
    get_yaml_handler,
    load_yaml,
    dump_yaml,
    create_backup,
    compute_checksum,
    atomic_write
)

# Get pre-configured YAML handler
yaml = get_yaml_handler(preserve_quotes=True)

# Safe YAML operations
data = load_yaml(file_path)
dump_yaml(data, file_path, create_backup=True)

# Backup utilities
backup_path = create_backup(file_path, backup_dir)

# Checksums
checksum = compute_checksum(file_path)

# Atomic writes (write to temp, then move)
atomic_write(file_path, data, yaml_handler=yaml)
```

**Dependencies:**
- `ruamel.yaml` (required)
- `pathlib`, `shutil`, `hashlib`, `tempfile` (stdlib)

---

### 5. Person Data Models Module (`PyBiographical.persons.models`)

**Source:** `metadata/scripts/scrub_person_data.py`

**Extract:**
- `PersonFile` dataclass
- `DetectionResult` dataclass
- `ValidationIssue` dataclass (if not in validation module)

**API Design:**
```python
from pybiographical.persons.models import PersonFile, ValidationIssue

# Data structures for person processing
person = PersonFile(
    path=Path("person.yaml"),
    dataset_type="biographical dataset",
    person_id="I382302780374",
    name_full="Hans Mueller",
    # ... other fields
)

# Validation results
issue = ValidationIssue(
    severity="ERROR",
    issue="Missing required field: person_id",
    fixable=False
)
```

**Dependencies:**
- `dataclasses` (stdlib)
- `pathlib` (stdlib)
- `typing` (stdlib)

---

## Dependencies

### New Dependencies for PyBiographical v0.2.0

Add to `pyproject.toml`:

```toml
[project]
dependencies = [
    "ruamel.yaml>=0.17.0",
]

[project.optional-dependencies]
matching = [
    "rapidfuzz>=3.0.0",
]
full = [
    "ruamel.yaml>=0.17.0",
    "rapidfuzz>=3.0.0",
]
```

### Installation Options

```bash
# Core functionality only
pip install git+https://github.com/username/PyBiographical.git

# With fuzzy matching support
pip install "git+https://github.com/username/PyBiographical.git#egg=PyBiographical[matching]"

# Full installation
pip install "git+https://github.com/username/PyBiographical.git#egg=PyBiographical[full]"
```

---

## Migration Steps

### Phase 1: Create New Modules (Weeks 1-2)

1. **Create directory structure** in PyBiographical
2. **Extract validation module** (`biographical/validation.py`)
   - Copy validation logic from `validate_person_yaml.py`
   - Refactor into reusable functions
   - Add unit tests
3. **Extract YAML utilities** (`io/yaml_utils.py`)
   - Extract common YAML patterns
   - Add backup utilities
   - Add unit tests
4. **Extract fuzzy matching** (`matching/fuzzy.py`)
   - Extract normalization functions
   - Extract matching algorithms
   - Add unit tests
5. **Extract data models** (`biographical/models.py`)
   - Extract dataclasses
   - Document fields
6. **Extract CRUD operations** (`biographical/crud.py`)
   - Copy PersonCRUD class
   - Update imports to use PyBiographical modules
   - Add unit tests

### Phase 2: Update Dependencies (Week 2)

7. **Update pyproject.toml** with new dependencies
8. **Bump version** to 0.2.0
9. **Update README** with new modules
10. **Generate API documentation**

### Phase 3: Refactor Metadata Scripts (Week 3)

11. **Update metadata project dependencies**
    - Add PyBiographical to requirements
12. **Refactor validate_person_yaml.py**
    - Import from pybiographical.biographical.validation
    - Remove duplicated code
    - Keep CLI wrapper
13. **Refactor person_crud.py**
    - Import from pybiographical.biographical.crud
    - Keep CLI wrapper
14. **Refactor scrub_person_data.py**
    - Import from pybiographical.matching.fuzzy
    - Import from pybiographical.biographical.models
    - Keep scrubbing-specific logic
15. **Test all scripts** with new library structure

### Phase 4: Documentation and Testing (Week 4)

16. **Write API documentation** (docs/API.md)
17. **Write usage examples** (docs/EXAMPLES.md)
18. **Write migration guide** for other projects
19. **Add integration tests**
20. **Publish release** v0.2.0

---

## Backward Compatibility

### For Existing Metadata Scripts

**Option 1: Direct Migration (Recommended)**
- Update imports to use PyBiographical
- Remove duplicated code
- Keep CLI wrappers intact

**Option 2: Compatibility Shims**
- Keep old function names as wrappers
- Add deprecation warnings
- Phase out over 2-3 releases

### Example Migration

**Before:**
```python
# metadata/scripts/person_crud.py
class PersonCRUD:
    def __init__(self, persons_dir, backup_dir, archive_dir):
        # ... implementation
```

**After:**
```python
# metadata/scripts/person_crud.py
from pybiographical.biographical.crud import PersonCRUD

# CLI wrapper remains the same
def main():
    crud = PersonCRUD(...)
    # ... CLI logic
```

---

## Testing Strategy

### Unit Tests

Each module gets comprehensive unit tests:

```
tests/
├── test_validation.py       # Test validation functions
├── test_crud.py             # Test CRUD operations
├── test_fuzzy.py            # Test fuzzy matching
├── test_yaml_utils.py       # Test YAML utilities
└── test_models.py           # Test data models
```

### Integration Tests

Test interaction between modules:
- CRUD operations with validation
- Fuzzy matching with CRUD search
- YAML utilities with all modules

### Test Data

Create minimal test datasets:
```
tests/fixtures/
├── persons/
│   ├── valid_person.yaml
│   ├── invalid_person.yaml
│   └── duplicate_person.yaml
└── expected_results/
```

---

## Documentation

### API Documentation (docs/API.md)

- Module overview
- Class/function signatures
- Parameter descriptions
- Return value descriptions
- Usage examples
- Error handling

### Usage Examples (docs/EXAMPLES.md)

- Common use cases
- Code snippets
- Best practices
- Integration examples

### Migration Guide (docs/MIGRATION_GUIDE.md)

- How to update existing scripts
- Breaking changes (if any)
- Deprecation notices
- Version compatibility matrix

---

## Version Roadmap

### v0.1.0 (Current)
- RAM disk utilities

### v0.2.0 (This Migration)
- Genealogy validation
- Person CRUD operations
- Fuzzy matching
- YAML utilities
- Data models

### v0.3.0 (Future)
- Location resolution utilities
- Photo management utilities
- biographical dataset export/import
- Enhanced search capabilities

### v1.0.0 (Future)
- Stable API
- Full documentation
- Comprehensive test coverage
- Performance optimizations

---

## Success Metrics

### Code Quality
- [ ] 80%+ test coverage
- [ ] No breaking changes for metadata scripts
- [ ] All existing tests pass
- [ ] No linter warnings

### Documentation
- [ ] API docs for all public functions
- [ ] Usage examples for each module
- [ ] Migration guide for projects
- [ ] README with quick start

### Performance
- [ ] No performance regression in metadata scripts
- [ ] CRUD operations < 100ms for typical files
- [ ] Fuzzy matching < 500ms for 10k person dataset

---

## Risk Assessment

### Low Risk
- YAML utilities extraction (well-isolated)
- Data models extraction (pure data structures)
- Validation functions (stateless)

### Medium Risk
- Fuzzy matching (complex algorithms, performance-sensitive)
- CRUD operations (file I/O, transaction safety)

### Mitigation Strategies
1. **Extensive testing** before migration
2. **Keep backups** of metadata project state
3. **Incremental migration** (module by module)
4. **Version pinning** in metadata project
5. **Rollback plan** if issues arise

---

## Timeline

| Phase | Tasks | Duration | Completion |
|-------|-------|----------|------------|
| 1 | Create modules, extract code | 2 weeks | □ |
| 2 | Update dependencies, documentation | 1 week | □ |
| 3 | Refactor metadata scripts | 1 week | □ |
| 4 | Testing, documentation, release | 1 week | □ |

**Total Estimated Time:** 4-5 weeks

---

## Rollback Plan

If migration causes issues:

1. **Revert metadata project** to use local implementations
2. **Pin PyBiographical** to v0.1.0 in metadata
3. **Fix issues** in PyBiographical
4. **Re-test** thoroughly
5. **Re-migrate** when stable

---

## Next Steps

1. ✅ Review this migration plan
2. □ Get approval for extraction approach
3. □ Create feature branch in PyBiographical: `feature/biographical-modules`
4. □ Begin Phase 1: Create new modules
5. □ Set up continuous integration for PyBiographical
6. □ Begin incremental extraction and testing

---

## Questions / Decisions Needed

1. **Should we extract photo management utilities?** (from add_person_photo.py)
   - Requires: requests, pillow
   - Size: ~500 lines
   - Recommendation: Include in v0.3.0

2. **Should we extract location resolution?** (from location_resolver.py)
   - Dependencies: None (uses locations.json)
   - Size: ~300 lines
   - Recommendation: Include in v0.2.0 or v0.3.0

3. **Versioning strategy for breaking changes?**
   - Recommendation: Semantic versioning, deprecation warnings

4. **Should PyBiographical be published to PyPI?**
   - Recommendation: Start with GitHub, publish to PyPI at v1.0.0

---

## Conclusion

This migration will significantly improve code reusability and maintainability across your biographical projects. The modular structure will make it easy to add new features and projects while keeping the core utilities battle-tested and well-documented.

**Estimated Benefits:**
- **-2000 lines** of duplicated code in metadata project
- **+100%** code reuse potential across projects
- **Faster development** for new features
- **Better testing** through isolation
- **Easier maintenance** through centralization

Ready to proceed! 🚀
