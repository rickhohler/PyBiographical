#!/bin/bash
# prepare-release.sh - Format code and prepare for release
# Usage: ./scripts/prepare-release.sh [patch|minor|major]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== PyBiographical Release Preparation ===${NC}\n"

# Step 1: Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    git status -s
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 2: Format Python code
echo -e "${BLUE}📝 Formatting Python code...${NC}"
if command -v black &> /dev/null; then
    black src/ --line-length 100
    echo -e "${GREEN}✓ Code formatted with black${NC}\n"
else
    echo -e "${YELLOW}⚠️  black not installed, skipping formatting${NC}"
    echo "   Install with: pip install black"
    echo ""
fi

# Step 3: Lint code
echo -e "${BLUE}🔍 Linting code...${NC}"
if command -v ruff &> /dev/null; then
    ruff check src/ --fix || echo -e "${YELLOW}⚠️  Some linting issues remain${NC}"
    echo -e "${GREEN}✓ Code linted with ruff${NC}\n"
else
    echo -e "${YELLOW}⚠️  ruff not installed, skipping linting${NC}"
    echo "   Install with: pip install ruff"
    echo ""
fi

# Step 4: Get current version
CURRENT_VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
echo -e "${BLUE}Current version: ${GREEN}v${CURRENT_VERSION}${NC}\n"

# Step 5: Determine new version
VERSION_TYPE="${1:-}"
if [[ -z "$VERSION_TYPE" ]]; then
    echo -e "${YELLOW}Version bump type not specified${NC}"
    echo "Usage: $0 [patch|minor|major]"
    echo ""
    echo "Examples:"
    echo "  patch: 0.2.0 → 0.2.1 (bug fixes)"
    echo "  minor: 0.2.0 → 0.3.0 (new features)"
    echo "  major: 0.2.0 → 1.0.0 (breaking changes)"
    echo ""
    read -p "Enter version type (patch/minor/major) or press Enter to skip: " VERSION_TYPE
    
    if [[ -z "$VERSION_TYPE" ]]; then
        echo -e "${YELLOW}Skipping version bump${NC}\n"
        NEW_VERSION="$CURRENT_VERSION"
    fi
fi

# Calculate new version
if [[ -n "$VERSION_TYPE" ]]; then
    IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION"
    MAJOR="${version_parts[0]}"
    MINOR="${version_parts[1]}"
    PATCH="${version_parts[2]}"
    
    case "$VERSION_TYPE" in
        patch)
            PATCH=$((PATCH + 1))
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        *)
            echo -e "${RED}❌ Invalid version type: $VERSION_TYPE${NC}"
            echo "Must be: patch, minor, or major"
            exit 1
            ;;
    esac
    
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
    echo -e "${BLUE}New version will be: ${GREEN}v${NEW_VERSION}${NC}\n"
    
    # Update pyproject.toml
    sed -i.bak "s/version = \"${CURRENT_VERSION}\"/version = \"${NEW_VERSION}\"/" pyproject.toml
    rm pyproject.toml.bak
    echo -e "${GREEN}✓ Updated version in pyproject.toml${NC}\n"
fi

# Step 6: Update CHANGELOG.md
echo -e "${BLUE}📋 Updating CHANGELOG.md...${NC}"
TODAY=$(date +%Y-%m-%d)

if [[ -n "$VERSION_TYPE" ]] && [[ "$NEW_VERSION" != "$CURRENT_VERSION" ]]; then
    # Create new version section in CHANGELOG
    if grep -q "## \[Unreleased\]" CHANGELOG.md; then
        # Replace [Unreleased] with new version
        sed -i.bak "/## \[Unreleased\]/a\\
\\
## [${NEW_VERSION}] - ${TODAY}" CHANGELOG.md
        
        # Update comparison links at bottom
        if grep -q "\[Unreleased\]:" CHANGELOG.md; then
            sed -i.bak "s|\[Unreleased\]:.*|[Unreleased]: https://github.com/username/PyBiographical/compare/v${NEW_VERSION}...HEAD\\
[${NEW_VERSION}]: https://github.com/username/PyBiographical/compare/v${CURRENT_VERSION}...v${NEW_VERSION}|" CHANGELOG.md
        fi
        
        rm CHANGELOG.md.bak
        echo -e "${GREEN}✓ Added version ${NEW_VERSION} to CHANGELOG.md${NC}"
        echo -e "${YELLOW}⚠️  Please review and edit CHANGELOG.md before committing${NC}\n"
    else
        echo -e "${YELLOW}⚠️  No [Unreleased] section found in CHANGELOG.md${NC}"
        echo "   Please update CHANGELOG.md manually"
        echo ""
    fi
else
    echo -e "${YELLOW}Skipping CHANGELOG update (no version change)${NC}\n"
fi

# Step 7: Show git status
echo -e "${BLUE}📊 Git status:${NC}"
git status -s
echo ""

# Step 8: Summary and next steps
echo -e "${GREEN}=== Preparation Complete ===${NC}\n"

if [[ "$NEW_VERSION" != "$CURRENT_VERSION" ]]; then
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review changes: git diff"
    echo "2. Review CHANGELOG.md and make any needed edits"
    echo "3. Commit: git add -A && git commit -m 'chore: release v${NEW_VERSION}'"
    echo "4. Tag: git tag v${NEW_VERSION}"
    echo "5. Push: git push origin main && git push origin v${NEW_VERSION}"
    echo ""
    echo -e "${YELLOW}This will trigger automated PyPI publishing!${NC}"
else
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review changes: git diff"
    echo "2. Commit: git add -A && git commit -m 'style: format code'"
    echo "3. Push: git push origin main"
fi

echo ""
