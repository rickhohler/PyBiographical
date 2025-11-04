# PyCommon Quick Start Guide

Fast guide to using `PyBiographical` in metadata projects.

## Installation

```bash
# From your project directory
pip install git+ssh://git@github.com/username/PyBiographical.git

# Or with optional fuzzy matching (recommended)
pip install "git+ssh://git@github.com/username/PyBiographical.git[matching]"
```

## Basic Usage

### 1. Person CRUD Operations

```python
from pybiographical.persons import PersonCRUD
from pathlib import Path

# Initialize
crud = PersonCRUD(
    persons_dir=Path("ORGANIZED/DATA/persons"),
    backup_dir=Path("ORGANIZED/BACKUPS"),
    archive_dir=Path("ORGANIZED/ARCHIVE")
)

# Create person (with automatic duplicate detection)
person = crud.create(
    given_names="Johann",
    surname="Johnson",
    birth_year=1825,
    birth_place="Schwenningen, Germany",
    gender="Male"
)

# Read by ID
person = crud.read("I382302780374")

# Search with fuzzy matching
results = crud.search(
    surname="Johnson",
    birth_year=1825,
    fuzzy=True,
    threshold=80
)

# Update (creates automatic backup)
crud.update("I382302780374", {
    'vital_events.birth.date': '1825-03-15'
})

# Delete (archives by default)
crud.delete("I382302780374", archive=True)
```

### 2. Validation

```python
from pybiographical.persons import validate_directory, fix_schema_version
from pathlib import Path

# Validate all files
results = validate_directory(Path("ORGANIZED/DATA/persons"))

# Check results
for result in results:
    if result.issues:
        print(f"{result.file.name}:")
        for issue in result.issues:
            print(f"  {issue.severity}: {issue.message}")

# Auto-fix schema versions
for result in results:
    if any("schema_version" in i.message for i in result.issues):
        fix_schema_version(result.file.path, make_backup=True)
```

### 3. Fuzzy Matching

```python
from pybiographical.matching import fuzzy_match_name, fuzzy_match_location

# Name matching (0-100 score)
score = fuzzy_match_name(
    "Hans Mueller",
    "John Johnson",
    check_alternates=["Hans"]
)
print(f"Name match: {score}%")

# Location matching
score = fuzzy_match_location(
    "Harvey, North Dakota",
    "Harvey, ND"
)
print(f"Location match: {score}%")
```

### 4. YAML Operations

```python
from pybiographical.io import load_yaml, dump_yaml, create_backup

# Load
data = load_yaml("person.yaml")

# Modify
data['vital_events']['birth']['date'] = "1825-03-15"

# Backup before saving
backup_path = create_backup("person.yaml", Path("BACKUPS"))

# Save
dump_yaml(data, "person.yaml")
```

## Common Patterns

### Batch Import with Deduplication

```python
from pybiographical.persons import PersonCRUD

crud = PersonCRUD(
    persons_dir=Path("ORGANIZED/DATA/persons"),
    backup_dir=Path("ORGANIZED/BACKUPS"),
    archive_dir=Path("ORGANIZED/ARCHIVE")
)

# Import from external source
for record in external_data:
    try:
        person = crud.create(
            given_names=record['given_names'],
            surname=record['surname'],
            birth_year=record['birth_year'],
            check_duplicates=True  # Returns existing if 95%+ match
        )
        print(f"✓ {person['person_id']}")
    except FileExistsError:
        print(f"✗ Already exists: {record['surname']}")
```

### Find Duplicates

```python
from pybiographical.persons import PersonCRUD

crud = PersonCRUD(persons_dir=Path("ORGANIZED/DATA/persons"), ...)

# Search for potential duplicates
def find_duplicates(person_id):
    person = crud.read(person_id)
    
    matches = crud.search(
        surname=person['name']['surname'],
        given_names=person['name']['given_names'],
        birth_year=person.get('vital_events', {}).get('birth', {}).get('year'),
        fuzzy=True,
        threshold=75
    )
    
    # Filter out self
    duplicates = [(p, conf) for p, conf in matches if p['person_id'] != person_id]
    
    return duplicates

# Check specific person
dupes = find_duplicates("I382302780374")
for dup_person, confidence in dupes:
    print(f"{confidence}% - {dup_person['person_id']} {dup_person['name']['full_name']}")
```

### Validate and Fix Directory

```python
from pybiographical.persons import validate_directory, fix_schema_version
from pathlib import Path

def validate_and_fix(directory):
    results = validate_directory(directory)
    
    fixed_count = 0
    for result in results:
        for issue in result.issues:
            if "schema_version" in issue.message:
                print(f"Fixing: {result.file.name}")
                success = fix_schema_version(result.file.path, make_backup=True)
                if success:
                    fixed_count += 1
    
    print(f"\nValidated {len(results)} files")
    print(f"Fixed {fixed_count} schema versions")
    
    # Re-validate
    results = validate_directory(directory)
    remaining_issues = sum(len(r.issues) for r in results)
    print(f"Remaining issues: {remaining_issues}")

# Run
validate_and_fix(Path("ORGANIZED/DATA/persons"))
```

### High-Performance Batch Operations

```python
from pybiographical.persons import PersonCRUD
from pybiographical import RAMDiskContext
from pathlib import Path

# Use RAM disk for speed
with RAMDiskContext(prefix="metadata", copy_back_to=Path("output")) as ramdisk:
    if ramdisk.available:
        crud = PersonCRUD(
            persons_dir=ramdisk.temp_dir / "persons",
            backup_dir=ramdisk.temp_dir / "backups",
            archive_dir=ramdisk.temp_dir / "archive"
        )
        
        # Fast batch operations
        for i in range(1000):
            crud.create(
                given_names=f"Person{i}",
                surname="Smith",
                birth_year=1900 + i,
                check_duplicates=False  # Skip for speed
            )
        
        # Files automatically copied to output/ on exit
```

## Configuration

### Logging

```python
import logging

# Enable PyBiographical logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Or just for PyBiographical
logging.getLogger('PyBiographical').setLevel(logging.DEBUG)
```

### Fuzzy Matching Thresholds

```python
# Default thresholds
DEFAULT_THRESHOLD = 60      # Minimum match score
DUPLICATE_THRESHOLD = 80    # Potential duplicate
HIGH_CONFIDENCE = 95        # Very likely duplicate

# Customize search
results = crud.search(
    surname="Johnson",
    fuzzy=True,
    threshold=85  # Higher threshold = fewer, better matches
)
```

## Troubleshooting

### "rapidfuzz not available"

```bash
# Install optional fuzzy matching dependency
pip install rapidfuzz

# Or install PyBiographical with extras
pip install "git+ssh://git@github.com/username/PyBiographical.git[matching]"
```

### "No backups found"

Backups are timestamped and stored in the backup directory:
```
ORGANIZED/BACKUPS/
  I382302780374_Hans_Mueller_20251103_161745.yaml
  I382302780374_Hans_Mueller_20251103_162315.yaml
```

List available backups:
```python
backups = crud.list_backups("I382302780374")
for backup in backups:
    print(backup.name)
```

### Schema version errors

Auto-fix with backup:
```python
from pybiographical.persons import fix_schema_version

fixed = fix_schema_version("person.yaml", make_backup=True)
if fixed:
    print("Schema version updated")
```

## Next Steps

- See [README.md](README.md) for full API documentation
- Check out example scripts in your metadata project
- Review [pyproject.toml](pyproject.toml) for available extras

## Support

For issues or questions:
- GitHub: https://github.com/username/PyBiographical
- Project repos: biographical, metadata, media-tagging
