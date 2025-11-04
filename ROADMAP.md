# PyBiographical Roadmap

Future enhancements and migration opportunities for PyBiographical and consuming projects.

---

## Current Status (v0.2.0)

✅ **Complete:**
- YAML I/O utilities
- Person metadata validation
- Fuzzy name/location matching
- PersonCRUD with full CRUD operations
- Integration tests
- Comprehensive documentation

✅ **Projects Updated:**
- metadata (full migration - Phases 1-3)
- biographical (requirements updated)
- media-tagging (requirements updated)

---

## Short-Term Opportunities (v0.2.1 - v0.2.x)

### 1. Metadata Project - Remaining Scripts
**Effort:** Low-Medium | **Impact:** Medium | **Priority:** Optional

Migrate remaining 7 scripts to use PyBiographical utilities:

**Scripts:**
- `add_person_photo.py` - Replace ruamel.yaml with PyBiographical.io
- `create_location_dataset.py` - Replace ruamel.yaml with PyBiographical.io
- `export_to_gedcom.py` - Replace ruamel.yaml with PyBiographical.io
- `link_person_locations.py` - Replace ruamel.yaml with PyBiographical.io
- `migrate_person_ids.py` - Replace ruamel.yaml with PyBiographical.io
- `person_bulk_ops.py` - Replace ruamel.yaml + consider using PersonCRUD
- `scrub_person_data.py` - Replace rapidfuzz with PyBiographical.matching

**Benefits:**
- Full YAML standardization across all scripts
- Consistent fuzzy matching
- ~200-300 more lines of duplicate code removed

**Approach:**
- Replace `from ruamel.yaml import YAML` with `from pybiographical.io import get_yaml_handler, load_yaml, dump_yaml`
- Replace `from rapidfuzz import fuzz` with `from pybiographical.matching import fuzzy_match_name`
- Update YAML read/write calls to use PyBiographical functions
- Test each script individually

---

### 2. Genealogy Project - Script Migration
**Effort:** Medium | **Impact:** High | **Priority:** Recommended

Apply same migration pattern as metadata project:

**Candidates for Migration:**
- biographical dataset import scripts (likely using ruamel.yaml)
- Person matching/deduplication scripts (likely using rapidfuzz)
- Validation scripts

**Process:**
1. Identify scripts using ruamel.yaml/rapidfuzz
2. Follow metadata project migration pattern
3. Create integration tests
4. Migrate phase-by-phase

**Timeline:** 4-6 hours

---

### 3. Media-Tagging Project - Person Metadata Support
**Effort:** Low | **Impact:** Medium | **Priority:** Optional

Add person metadata capabilities to media-tagging:

**Use Cases:**
- Tag photos with person metadata
- Link photos to person records
- Search photos by person name (fuzzy matching)

**Implementation:**
- Import PersonCRUD from pybiographical
- Add scripts for person-photo linking
- Use fuzzy matching for name disambiguation

**Timeline:** 2-3 hours

---

## Medium-Term Enhancements (v0.3.0)

### 1. Location Module
**Effort:** High | **Impact:** High | **Priority:** High

Extract location resolution logic into PyBiographical:

**Features:**
- Location data models (Place, Address, Coordinates)
- Location normalization (city/state/country)
- Geocoding integration
- Location matching with fuzzy search
- Place hierarchy (city → state → country)

**Modules:**
```
PyBiographical/
├── locations/
│   ├── models.py      # Place, Address, Coordinates
│   ├── resolver.py    # Location resolution
│   ├── geocoding.py   # Geocoding APIs
│   └── matching.py    # Location fuzzy matching
```

**Benefits:**
- Shared location logic across projects
- Consistent place name handling
- Geocoding support for mapping

**Timeline:** 8-12 hours

---

### 2. Artifact Metadata Module
**Effort:** High | **Impact:** High | **Priority:** Medium

Create artifact/media metadata management:

**Features:**
- Artifact data models (Photo, Document, Recording)
- Artifact CRUD operations
- Metadata extraction (EXIF, OCR text)
- Artifact-person linking
- Collection management

**Modules:**
```
PyBiographical/
├── artifacts/
│   ├── models.py      # Photo, Document, Recording
│   ├── crud.py        # ArtifactCRUD
│   ├── metadata.py    # EXIF, metadata extraction
│   └── linking.py     # Link artifacts to persons
```

**Use Cases:**
- Media-tagging project (primary user)
- Genealogy project (photos, documents)
- Metadata project (artifact management)

**Timeline:** 12-16 hours

---

### 3. Relationship Module
**Effort:** Medium | **Impact:** Medium | **Priority:** Low

Add relationship management to person metadata:

**Features:**
- Relationship data models (Parent, Spouse, Sibling)
- Relationship validation
- Family tree traversal
- Relationship CRUD

**Modules:**
```
PyBiographical/
├── persons/
│   └── relationships.py  # Relationship management
```

**Timeline:** 6-8 hours

---

## Long-Term Vision (v0.4.0+)

### 1. Web Interface
**Effort:** Very High | **Impact:** High

Web-based interface for metadata management:

**Features:**
- Person CRUD via web UI
- Photo upload and tagging
- Fuzzy search interface
- Family tree visualization
- Duplicate detection UI

**Stack:**
- FastAPI backend
- React frontend
- PostgreSQL database

**Timeline:** 40-60 hours

---

### 2. CLI Tool
**Effort:** Medium | **Impact:** Medium

Unified CLI for all PyBiographical operations:

```bash
# Person operations
PyBiographical person create --given-names "John" --surname "Doe"
PyBiographical person search --surname "Johnson" --fuzzy
PyBiographical person validate data/persons/

# Artifact operations
PyBiographical artifact add photo.jpg --person I382302780374
PyBiographical artifact search --person "John Doe"

# Location operations
PyBiographical location resolve "Harvey, ND"
PyBiographical location geocode "123 Main St"
```

**Implementation:**
- Click-based CLI
- Subcommands for each module
- JSON output support
- Shell completion

**Timeline:** 8-12 hours

---

### 3. Export/Import
**Effort:** Medium-High | **Impact:** Medium

Support for multiple formats:

**Features:**
- biographical dataset export/import
- JSON export/import
- CSV export
- an online data source format
- FamilySearch format

**Timeline:** 12-16 hours

---

## Performance Enhancements

### 1. Database Backend (Optional)
**Effort:** Very High | **Impact:** High

Replace file-based storage with database:

**Options:**
- SQLite (simple, local)
- PostgreSQL (robust, scalable)

**Benefits:**
- Faster search (indexed queries)
- Better concurrent access
- Transaction support
- Relationship queries

**Tradeoffs:**
- More complex setup
- Less portable
- Migration from YAML files needed

**Timeline:** 20-30 hours

---

### 2. Caching Layer
**Effort:** Low | **Impact:** Medium

Add caching for frequently accessed data:

**Implementation:**
- In-memory LRU cache for person records
- Cache validation results
- Cache fuzzy match scores

**Benefits:**
- Faster repeated lookups
- Reduced file I/O
- Better performance for large datasets

**Timeline:** 4-6 hours

---

## Testing & Quality

### 1. Expanded Test Coverage
**Effort:** Medium | **Impact:** High | **Priority:** High

Increase test coverage across all modules:

**Current:** ~16 integration tests for metadata project  
**Target:** 100+ tests covering all PyBiographical modules

**Areas:**
- Unit tests for all PyBiographical modules
- Integration tests for each consuming project
- Performance benchmarks
- Edge case testing

**Timeline:** 8-12 hours

---

### 2. CI/CD Pipeline
**Effort:** Medium | **Impact:** Medium

Automated testing and deployment:

**Features:**
- GitHub Actions for automated tests
- Automated releases on tag
- Test coverage reporting
- Linting (black, ruff)

**Timeline:** 4-6 hours

---

### 3. Documentation
**Effort:** Medium | **Impact:** Medium

Enhanced documentation:

**Additions:**
- API reference (auto-generated from docstrings)
- Tutorial videos
- Architecture diagrams
- Troubleshooting guide
- Performance tuning guide

**Timeline:** 8-10 hours

---

## Migration Priorities

### Immediate (Next Session)
1. ✅ **Done:** Core PyBiographical v0.2.0 release
2. ✅ **Done:** Metadata project Phases 1-3 migration
3. **Optional:** Metadata remaining scripts (7 scripts)

### This Week
1. Monitor metadata project for issues
2. Consider biographical project Phase 1 (YAML utilities)
3. Plan location module extraction

### This Month
1. Complete biographical project migration
2. Start location module development
3. Expand test coverage

### This Quarter
1. Release PyBiographical v0.3.0 (locations, artifacts)
2. Migrate media-tagging project
3. Begin web interface planning

---

## Decision Points

### Should We Migrate Remaining Metadata Scripts?
**Pros:**
- Complete standardization
- Remove all duplicate YAML code
- Consistent fuzzy matching

**Cons:**
- Diminishing returns (scripts work fine)
- Time investment for optional improvement
- Risk of breaking working code

**Recommendation:** Do incrementally as scripts need updates

---

### Should We Add Database Support?
**Pros:**
- Much faster search (10-100x)
- Better for large datasets (100k+ persons)
- Relationship queries easier

**Cons:**
- Significant complexity
- Migration effort from YAML
- Less portable

**Recommendation:** Stay file-based for now, revisit if performance becomes issue

---

### Should We Build Web Interface?
**Pros:**
- Easier for non-technical users
- Better visualization
- Collaborative features possible

**Cons:**
- Major time investment
- Requires hosting
- Maintenance overhead

**Recommendation:** Start with CLI improvements, web UI later if needed

---

## Success Metrics

### v0.2.0 (Current)
- ✅ 3 projects using PyBiographical
- ✅ 1,113 lines of duplicate code removed
- ✅ 16 integration tests passing
- ✅ 11,506 person files validated

### v0.3.0 (Target)
- 3 projects fully migrated
- Location module in production use
- 100+ tests passing
- Performance benchmarks established

### v0.4.0 (Target)
- Artifact module in production use
- CLI tool released
- Export/import for major formats
- Web UI beta available

---

## Notes

- All roadmap items are **optional enhancements**
- Current v0.2.0 is **production-ready** and **complete**
- Focus on **stability and incremental improvements**
- **Measure impact** before major refactoring
- **Keep backward compatibility** as top priority

---

## Questions to Consider

1. Are there pain points in current workflow that PyBiographical could address?
2. Which scripts are used most frequently in daily work?
3. Are there performance bottlenecks with current file-based approach?
4. Would other team members benefit from a web interface?
5. Are there other projects that could use PyBiographical?

---

**Last Updated:** November 3, 2025  
**Version:** 0.2.0  
**Status:** Production-ready, optional enhancements planned
