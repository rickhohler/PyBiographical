# Migration Guide: Integrating PyBiographical into Existing Projects

Guide for migrating existing metadata/biographical projects to use `PyBiographical`.

## Overview

`PyBiographical` v0.2.0 extracts reusable components from metadata projects:
- YAML I/O utilities → `PyBiographical.io`
- Person metadata models → `PyBiographical.persons.models`
- Validation logic → `PyBiographical.persons.validation`
- Fuzzy matching → `PyBiographical.matching`
- CRUD operations → `PyBiographical.persons.crud`

## Installation

### 1. Add to requirements.txt

```txt
# In your project's requirements.txt
git+ssh://git@github.com/username/PyBiographical.git@v0.2.0#egg=PyBiographical[matching]
```

### 2. Install

```bash
pip install -r requirements.txt
```

## Migration Checklist

### Phase 1: YAML Utilities (Easy - 15 min)

**Before:**
```python
from ruamel.yaml import YAML
import hashlib
from pathlib import Path

yaml = YAML()
yaml.preserve_quotes = True

def load_yaml(file_path):
    with open(file_path, 'r') as f:
        return yaml.load(f)
```

**After:**
```python
from pybiographical.io import load_yaml, dump_yaml, create_backup

data = load_yaml(file_path)
dump_yaml(data, file_path)
backup_path = create_backup(file_path, backup_dir)
```

**Files to Update:**
- Any script with `ruamel.yaml` imports
- Functions named `load_yaml`, `save_yaml`, `create_backup`

**Search & Replace:**
```bash
# Find usages
grep -r "from ruamel.yaml import" scripts/
grep -r "def load_yaml" scripts/
grep -r "def save_yaml" scripts/

# Update imports
# Manual: Replace custom YAML functions with PyBiographical imports
```

---

### Phase 2: Validation (Moderate - 30 min)

**Before:**
```python
def validate_person_yaml(file_path):
    data = load_yaml(file_path)
    issues = []
    
    # Schema version check
    if 'schema_version' not in data:
        issues.append("Missing schema_version")
    
    # Required fields
    if 'person_id' not in data:
        issues.append("Missing person_id")
    
    # ... more validation
    
    return issues
```

**After:**
```python
from pybiographical.persons import validate_person_yaml, validate_directory

# Single file
issues = validate_person_yaml(file_path)

# Directory
results = validate_directory(persons_dir)
for result in results:
    if result.issues:
        print(f"{result.file.name}: {result.issues}")
```

**Files to Update:**
- `validate_person_yaml.py` → Delete (use `PyBiographical.persons.validate_person_yaml`)
- Scripts that call validation functions
- Schema version fixing scripts

**Migration Steps:**
1. **Identify validation scripts:**
   ```bash
   find scripts/ -name "*validat*" -o -name "*check*"
   ```

2. **Replace validation calls:**
   - Import from `PyBiographical.persons`
   - Remove custom validation functions
   - Update function signatures if needed

3. **Test:**
   ```bash
   # Run validation on test directory
   python scripts/validate_persons.py ORGANIZED/DATA/persons
   ```

---

### Phase 3: Fuzzy Matching (Moderate - 45 min)

**Before:**
```python
from rapidfuzz import fuzz

def fuzzy_match_name(name1, name2):
    # Custom normalization
    n1 = name1.lower().replace(',', '').strip()
    n2 = name2.lower().replace(',', '').strip()
    
    # Fuzzy matching
    score = fuzz.ratio(n1, n2)
    return score
```

**After:**
```python
from pybiographical.matching import (
    fuzzy_match_name,
    fuzzy_match_location,
    normalize_name,
    normalize_location
)

# Name matching with alternates
score = fuzzy_match_name(
    "Hans Mueller",
    "John Johnson",
    check_alternates=["Hans", "Johannes"]
)

# Location matching
score = fuzzy_match_location("Harvey, ND", "Harvey, North Dakota")
```

**Files to Update:**
- `fuzzy_matching.py` or similar
- Duplicate detection scripts
- Person matching/merging scripts

**Migration Steps:**
1. **Find fuzzy matching code:**
   ```bash
   grep -r "rapidfuzz" scripts/
   grep -r "fuzz\." scripts/
   grep -r "def.*match" scripts/
   ```

2. **Replace with PyBiographical:**
   - Update imports
   - Replace custom normalization with `normalize_name()` / `normalize_location()`
   - Use `fuzzy_match_name()` instead of `fuzz.ratio()`
   - Leverage alternate spellings feature

3. **Update duplicate detection:**
   - Use `compute_match_confidence()` for overall scores
   - Use `get_detailed_match_breakdown()` for debugging

---

### Phase 4: CRUD Operations (Major - 2-3 hours)

**Before:**
```python
def create_person(given_names, surname, birth_year, **kwargs):
    person_id = generate_id()
    
    # Build data structure
    person_data = {
        'schema_version': '2.0.0',
        'person_id': person_id,
        'name': {
            'full_name': f"{given_names} {surname}",
            'given_names': given_names,
            'surname': surname
        }
    }
    
    # Add optional fields...
    
    # Check for duplicates (custom logic)
    existing = find_duplicate(given_names, surname, birth_year)
    if existing:
        print(f"Duplicate found: {existing['person_id']}")
        return existing
    
    # Save file
    filename = f"{person_id}_{sanitize(given_names)}_{sanitize(surname)}.yaml"
    save_yaml(person_data, persons_dir / filename)
    
    return person_data
```

**After:**
```python
from pybiographical.persons import PersonCRUD

# Initialize once
crud = PersonCRUD(
    persons_dir=Path("ORGANIZED/DATA/persons"),
    backup_dir=Path("ORGANIZED/BACKUPS"),
    archive_dir=Path("ORGANIZED/ARCHIVE")
)

# Create with automatic duplicate detection
person = crud.create(
    given_names=given_names,
    surname=surname,
    birth_year=birth_year,
    check_duplicates=True  # Automatic!
)
```

**Files to Update:**
- `person_crud.py` → Can be deleted or simplified
- `create_person.py`, `update_person.py`, etc.
- Import/export scripts

**Migration Steps:**

1. **Identify CRUD files:**
   ```bash
   find scripts/ -name "*crud*" -o -name "*create*" -o -name "*update*"
   ```

2. **Create PersonCRUD instance:**
   ```python
   # In a config or utility module
   from pybiographical.persons import PersonCRUD
   from pathlib import Path
   
   # Initialize (can be singleton or per-script)
   crud = PersonCRUD(
       persons_dir=Path("ORGANIZED/DATA/persons"),
       backup_dir=Path("ORGANIZED/BACKUPS"),
       archive_dir=Path("ORGANIZED/ARCHIVE")
   )
   ```

3. **Replace CRUD operations:**

   **Create:**
   ```python
   # Before
   person = create_person("Johann", "Johnson", 1825)
   
   # After
   person = crud.create("Johann", "Johnson", birth_year=1825)
   ```

   **Read:**
   ```python
   # Before
   person = read_person_by_id("I382302780374")
   
   # After
   person = crud.read("I382302780374")
   ```

   **Search:**
   ```python
   # Before
   matches = search_persons(surname="Johnson", birth_year=1825)
   
   # After
   results = crud.search(surname="Johnson", birth_year=1825, fuzzy=True)
   ```

   **Update:**
   ```python
   # Before
   update_person("I382302780374", {'birth_date': '1825-03-15'})
   
   # After
   crud.update("I382302780374", {'vital_events.birth.date': '1825-03-15'})
   ```

   **Delete:**
   ```python
   # Before
   delete_person("I382302780374")
   
   # After
   crud.delete("I382302780374", archive=True)
   ```

4. **Remove old CRUD functions:**
   - Delete `person_crud.py` (if fully replaced)
   - Remove duplicate detection logic (now built-in)
   - Remove custom ID generation (use `crud.create()`)

---

## Common Migration Patterns

### Pattern 1: Batch Import Script

**Before:**
```python
for record in gedcom_records:
    # Custom duplicate check
    existing = find_duplicate(record['name'], record['birth_year'])
    if existing:
        continue
    
    # Create person
    person = create_person(
        given_names=record['given_names'],
        surname=record['surname'],
        birth_year=record['birth_year']
    )
```

**After:**
```python
from pybiographical.persons import PersonCRUD

crud = PersonCRUD(persons_dir=..., backup_dir=..., archive_dir=...)

for record in gedcom_records:
    # Automatic duplicate detection
    person = crud.create(
        given_names=record['given_names'],
        surname=record['surname'],
        birth_year=record['birth_year'],
        check_duplicates=True  # Returns existing if 95%+ match
    )
```

---

### Pattern 2: Duplicate Detection Script

**Before:**
```python
def find_duplicates(persons_dir):
    persons = load_all_persons(persons_dir)
    
    duplicates = []
    for i, p1 in enumerate(persons):
        for p2 in persons[i+1:]:
            score = compute_similarity(p1, p2)
            if score >= 80:
                duplicates.append((p1, p2, score))
    
    return duplicates
```

**After:**
```python
from pybiographical.persons import PersonCRUD

crud = PersonCRUD(persons_dir=..., backup_dir=..., archive_dir=...)

def find_duplicates():
    # Get all person files
    for yaml_file in persons_dir.glob("*.yaml"):
        person = crud.read(yaml_file.stem.split('_')[0])
        
        # Search for matches
        matches = crud.search(
            surname=person['name']['surname'],
            given_names=person['name']['given_names'],
            birth_year=person.get('vital_events', {}).get('birth', {}).get('year'),
            fuzzy=True,
            threshold=80
        )
        
        # Filter out self
        duplicates = [m for m in matches if m[0]['person_id'] != person['person_id']]
        
        if duplicates:
            yield person, duplicates
```

---

### Pattern 3: Validation & Auto-Fix Script

**Before:**
```python
def validate_and_fix(directory):
    for yaml_file in directory.glob("*.yaml"):
        issues = validate_yaml(yaml_file)
        
        if "schema_version" in str(issues):
            # Custom fix logic
            data = load_yaml(yaml_file)
            data['schema_version'] = '2.0.0'
            
            # Manual backup
            backup = yaml_file.with_suffix('.yaml.bak')
            shutil.copy(yaml_file, backup)
            
            # Save
            save_yaml(data, yaml_file)
```

**After:**
```python
from pybiographical.persons import validate_directory, fix_schema_version

def validate_and_fix(directory):
    results = validate_directory(directory)
    
    for result in results:
        for issue in result.issues:
            if "schema_version" in issue.message:
                # Auto-fix with backup
                fix_schema_version(result.file.path, make_backup=True)
```

---

## Testing After Migration

### 1. Unit Tests

Create test file: `tests/test_pycommon_integration.py`

```python
import pytest
from pathlib import Path
from pybiographical.persons import PersonCRUD, validate_directory
from pybiographical.matching import fuzzy_match_name

@pytest.fixture
def crud(tmp_path):
    return PersonCRUD(
        persons_dir=tmp_path / "persons",
        backup_dir=tmp_path / "backups",
        archive_dir=tmp_path / "archive"
    )

def test_create_person(crud):
    person = crud.create("Johann", "Johnson", birth_year=1825)
    assert person['person_id'].startswith('I382')
    assert person['name']['full_name'] == "Hans Mueller"

def test_duplicate_detection(crud):
    # Create first
    p1 = crud.create("Johann", "Johnson", birth_year=1825)
    
    # Create duplicate (should return existing)
    p2 = crud.create("Johann", "Johnson", birth_year=1825, check_duplicates=True)
    
    assert p1['person_id'] == p2['person_id']

def test_fuzzy_matching():
    score = fuzzy_match_name("Hans Mueller", "John Johnson")
    assert score >= 80  # Should be high similarity
```

Run tests:
```bash
pytest tests/test_pycommon_integration.py -v
```

---

### 2. Integration Tests

Test with real data:

```bash
# 1. Validate existing data
python -m PyBiographical.persons.validation ORGANIZED/DATA/persons

# 2. Test CRUD operations
python scripts/test_crud.py

# 3. Test duplicate detection
python scripts/find_duplicates.py
```

---

### 3. Smoke Tests

Quick checks after migration:

```python
from pybiographical.persons import PersonCRUD, validate_directory
from pathlib import Path

# Initialize
crud = PersonCRUD(
    persons_dir=Path("ORGANIZED/DATA/persons"),
    backup_dir=Path("ORGANIZED/BACKUPS"),
    archive_dir=Path("ORGANIZED/ARCHIVE")
)

# 1. Read existing person
person = crud.read("I382302780374")
print(f"✓ Read: {person['name']['full_name']}")

# 2. Search
results = crud.search(surname="Johnson", fuzzy=True)
print(f"✓ Search: {len(results)} results")

# 3. Validate
issues = validate_directory(Path("ORGANIZED/DATA/persons"))
print(f"✓ Validate: {len(issues)} files checked")
```

---

## Troubleshooting

### Import Errors

**Error:** `ModuleNotFoundError: No module named 'PyBiographical'`

**Solution:**
```bash
# Reinstall PyBiographical
pip install --force-reinstall git+ssh://git@github.com/username/PyBiographical.git[matching]
```

---

### Rapidfuzz Warnings

**Warning:** `rapidfuzz not available, using exact matching only`

**Solution:**
```bash
# Install rapidfuzz
pip install rapidfuzz

# Or reinstall with extras
pip install "git+ssh://git@github.com/username/PyBiographical.git[matching]"
```

---

### Validation Failures

**Error:** `ValidationIssue: Missing schema_version`

**Solution:**
```python
from pybiographical.persons import fix_schema_version

# Auto-fix
fixed = fix_schema_version("person.yaml", make_backup=True)
```

---

### Path Issues

**Error:** `FileNotFoundError: persons directory not found`

**Solution:**
```python
# Ensure directories exist
from pathlib import Path

persons_dir = Path("ORGANIZED/DATA/persons")
persons_dir.mkdir(parents=True, exist_ok=True)

# Or let PersonCRUD create them
crud = PersonCRUD(
    persons_dir=persons_dir,  # Auto-created
    backup_dir=Path("ORGANIZED/BACKUPS"),
    archive_dir=Path("ORGANIZED/ARCHIVE")
)
```

---

## Rollback Plan

If issues occur:

1. **Keep old code temporarily:**
   ```bash
   # Don't delete old files immediately
   mv person_crud.py person_crud.py.old
   ```

2. **Use git branches:**
   ```bash
   # Create migration branch
   git checkout -b migrate-to-PyBiographical
   
   # If issues, revert
   git checkout main
   ```

3. **Test thoroughly before committing:**
   ```bash
   # Run all tests
   pytest tests/
   
   # Validate data
   python scripts/validate_all.py
   
   # Only commit if passing
   git commit -m "Migrate to PyBiographical v0.2.0"
   ```

---

## Benefits After Migration

✅ **Less code to maintain** - Remove 500+ lines of duplicate YAML/validation/matching code  
✅ **Better error handling** - Built-in validation and backup management  
✅ **Faster duplicate detection** - Optimized fuzzy matching with rapidfuzz  
✅ **Automatic backups** - All updates create timestamped backups  
✅ **Idempotent operations** - Safe to re-run scripts without duplicates  
✅ **Consistent behavior** - Same logic across all projects  

---

## Next Steps

1. Start with **Phase 1** (YAML utilities) - easiest and fastest
2. Move to **Phase 2** (validation) - moderate effort, high value
3. Tackle **Phase 3** (fuzzy matching) when ready
4. Complete **Phase 4** (CRUD) last - most impactful but requires testing

## Support

Questions or issues?
- Check [QUICKSTART.md](QUICKSTART.md) for examples
- Review [README.md](README.md) for API docs
- See PyBiographical tests for usage patterns
