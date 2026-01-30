#!/usr/bin/env bash
# =============================================================================
# AutoGPT Platform Release Script
# =============================================================================
# Creates a new release by:
# 1. Auto-incrementing version (or accepting override)
# 2. Syncing all 3 package versions atomically:
#    - autogpt_platform/frontend/package.json
#    - autogpt_platform/backend/pyproject.toml
#    - autogpt_platform/autogpt_libs/pyproject.toml
# 3. Creating and pushing a git tag
# 4. Creating a GitHub release to trigger platform-autogpt-deploy-prod.yml
#
# Usage:
#   mise run release              # Auto-increment patch version (interactive)
#   mise run release v1.2.3       # Use specific version
#   mise run release:major        # Increment major version
#   mise run release:minor        # Increment minor version
#   mise run release:patch        # Increment patch version
#   mise run release --yes        # Skip confirmation prompt
#   mise run release minor -y     # Combine version type with auto-confirm
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
YES_FLAG=false

# Version file paths
FRONTEND_PACKAGE_JSON="autogpt_platform/frontend/package.json"
BACKEND_PYPROJECT="autogpt_platform/backend/pyproject.toml"
LIBS_PYPROJECT="autogpt_platform/autogpt_libs/pyproject.toml"

# Get the latest git tag, default to v0.0.0 if none exists
get_latest_tag() {
    git fetch --tags --quiet 2>/dev/null || true
    local latest
    latest=$(git tag -l 'v*' --sort=-v:refname | head -n1)
    echo "${latest:-v0.0.0}"
}

# Get version from package.json
get_frontend_version() {
    if [[ ! -f "$FRONTEND_PACKAGE_JSON" ]]; then
        echo "0.0.0"
        return
    fi
    node -e "console.log(require('./$FRONTEND_PACKAGE_JSON').version)" 2>/dev/null || echo "0.0.0"
}

# Get version from backend pyproject.toml
get_backend_version() {
    if [[ ! -f "$BACKEND_PYPROJECT" ]]; then
        echo "0.0.0"
        return
    fi
    grep '^version = ' "$BACKEND_PYPROJECT" | sed 's/version = "\(.*\)"/\1/' || echo "0.0.0"
}

# Get version from libs pyproject.toml
get_libs_version() {
    if [[ ! -f "$LIBS_PYPROJECT" ]]; then
        echo "0.0.0"
        return
    fi
    grep '^version = ' "$LIBS_PYPROJECT" | sed 's/version = "\(.*\)"/\1/' || echo "0.0.0"
}

# Check if versions are synchronized
check_version_sync() {
    local frontend backend libs
    frontend=$(get_frontend_version)
    backend=$(get_backend_version)
    libs=$(get_libs_version)

    if [[ "$frontend" == "$backend" && "$backend" == "$libs" ]]; then
        echo "$frontend"
        return 0
    else
        return 1
    fi
}

# Detect version mismatch and suggest resolution
detect_version_mismatch() {
    local frontend backend libs
    frontend=$(get_frontend_version)
    backend=$(get_backend_version)
    libs=$(get_libs_version)

    echo -e "${YELLOW}Version mismatch detected:${NC}"
    echo "  Frontend: $frontend"
    echo "  Backend:  $backend"
    echo "  Libs:     $libs"
    echo ""

    # Find highest version
    local highest="$frontend"
    if [[ "$(printf '%s\n' "$backend" "$highest" | sort -V | tail -n1)" == "$backend" ]]; then
        highest="$backend"
    fi
    if [[ "$(printf '%s\n' "$libs" "$highest" | sort -V | tail -n1)" == "$libs" ]]; then
        highest="$libs"
    fi

    echo -e "${BLUE}Recommended: Synchronize to v${highest} (highest current version)${NC}"
    echo "Alternatively: Start fresh at v1.0.0"
    echo ""

    read -rp "Synchronize to v${highest}? [Y/n] " sync_choice
    if [[ "$sync_choice" =~ ^[Nn]$ ]]; then
        read -rp "Enter desired version (e.g., 1.0.0): " custom_version
        echo "v${custom_version#v}"
    else
        echo "v${highest}"
    fi
}

# Parse version into components
parse_version() {
    local version="${1#v}"  # Remove 'v' prefix
    IFS='.' read -r major minor patch <<< "$version"
    echo "$major $minor $patch"
}

# Increment version based on type
increment_version() {
    local current="$1"
    local type="${2:-patch}"

    read -r major minor patch <<< "$(parse_version "$current")"

    case "$type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch|*)
            patch=$((patch + 1))
            ;;
    esac

    echo "v${major}.${minor}.${patch}"
}

# Update frontend package.json version
update_frontend_version() {
    local version="${1#v}"  # Remove 'v' prefix

    if [[ ! -f "$FRONTEND_PACKAGE_JSON" ]]; then
        echo -e "${RED}Error: $FRONTEND_PACKAGE_JSON not found${NC}"
        return 1
    fi

    # Use node to update version (preserves formatting)
    node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('$FRONTEND_PACKAGE_JSON', 'utf8'));
        pkg.version = '$version';
        fs.writeFileSync('$FRONTEND_PACKAGE_JSON', JSON.stringify(pkg, null, 2) + '\n');
    "

    echo -e "${BLUE}  ✓ Updated frontend/package.json → ${version}${NC}"
}

# Update backend pyproject.toml version
update_backend_version() {
    local version="${1#v}"  # Remove 'v' prefix

    if [[ ! -f "$BACKEND_PYPROJECT" ]]; then
        echo -e "${RED}Error: $BACKEND_PYPROJECT not found${NC}"
        return 1
    fi

    # Use sed to update version field
    sed -i.bak "s/^version = .*/version = \"$version\"/" "$BACKEND_PYPROJECT"
    rm -f "${BACKEND_PYPROJECT}.bak"

    echo -e "${BLUE}  ✓ Updated backend/pyproject.toml → ${version}${NC}"
}

# Update libs pyproject.toml version
update_libs_version() {
    local version="${1#v}"  # Remove 'v' prefix

    if [[ ! -f "$LIBS_PYPROJECT" ]]; then
        echo -e "${RED}Error: $LIBS_PYPROJECT not found${NC}"
        return 1
    fi

    # Use sed to update version field
    sed -i.bak "s/^version = .*/version = \"$version\"/" "$LIBS_PYPROJECT"
    rm -f "${LIBS_PYPROJECT}.bak"

    echo -e "${BLUE}  ✓ Updated autogpt_libs/pyproject.toml → ${version}${NC}"
}

# Update all version files atomically
update_all_versions() {
    local version="$1"

    echo -e "${BLUE}Updating all version files...${NC}"
    update_frontend_version "$version"
    update_backend_version "$version"
    update_libs_version "$version"
    echo ""
}

# Generate release notes from commits since last tag
generate_release_notes() {
    local last_tag="$1"
    local notes=""

    # Get commits since last tag (or all commits if no tag)
    if git rev-parse "$last_tag" >/dev/null 2>&1; then
        notes=$(git log "${last_tag}..HEAD" --pretty=format:"- %s" --no-merges 2>/dev/null || echo "")
    else
        notes=$(git log --pretty=format:"- %s" --no-merges -20 2>/dev/null || echo "")
    fi

    if [[ -z "$notes" ]]; then
        notes="- Initial release with synchronized monorepo versioning"
    fi

    echo "$notes"
}

# Main
main() {
    local input=""
    local latest_tag
    local current_version
    local new_version

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                YES_FLAG=true
                shift
                ;;
            *)
                input="$1"
                shift
                ;;
        esac
    done

    # Ensure we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}"
        exit 1
    fi

    # Ensure working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        echo -e "${RED}Error: Working directory is not clean. Commit or stash changes first.${NC}"
        exit 1
    fi

    # Ensure gh CLI is authenticated
    if ! gh auth status >/dev/null 2>&1; then
        echo -e "${RED}Error: gh CLI not authenticated. Run 'gh auth login' first.${NC}"
        exit 1
    fi

    echo -e "${GREEN}=== AutoGPT Platform Release ===${NC}"
    echo ""

    # Check version synchronization
    if check_version_sync; then
        current_version="v$(check_version_sync)"
        echo -e "${GREEN}✓ Versions synchronized:${NC} $current_version"
    else
        current_version=$(detect_version_mismatch)

        # Update all versions to synchronized version
        update_all_versions "$current_version"

        # Commit synchronization
        git add "$FRONTEND_PACKAGE_JSON" "$BACKEND_PYPROJECT" "$LIBS_PYPROJECT"
        git commit -m "chore: synchronize monorepo versions to ${current_version#v}"

        echo -e "${GREEN}✓ Versions synchronized to:${NC} $current_version"
    fi

    latest_tag=$(get_latest_tag)
    echo -e "${BLUE}Latest git tag:${NC} $latest_tag"
    echo ""

    # Determine new version
    if [[ -z "$input" ]]; then
        # Interactive mode - prompt for version type
        new_version=$(increment_version "$current_version" "patch")
        echo -e "${YELLOW}Next version will be:${NC} $new_version"
        echo ""
        echo "Options:"
        echo "  [Enter] Accept $new_version (patch increment)"
        echo "  major   Increment major version"
        echo "  minor   Increment minor version"
        echo "  vX.Y.Z  Specify exact version"
        echo "  q       Quit"
        echo ""
        read -rp "Your choice: " choice

        case "$choice" in
            "")
                # Accept default
                ;;
            major)
                new_version=$(increment_version "$current_version" "major")
                ;;
            minor)
                new_version=$(increment_version "$current_version" "minor")
                ;;
            q|Q)
                echo "Aborted."
                exit 0
                ;;
            v*)
                new_version="$choice"
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac
    elif [[ "$input" == "major" || "$input" == "minor" || "$input" == "patch" ]]; then
        new_version=$(increment_version "$current_version" "$input")
    elif [[ "$input" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Ensure 'v' prefix
        new_version="v${input#v}"
    else
        echo -e "${RED}Invalid version format: $input${NC}"
        echo "Use: vX.Y.Z, major, minor, or patch"
        exit 1
    fi

    echo ""
    echo -e "${GREEN}Creating release:${NC} $new_version"
    echo ""

    # Generate release notes
    local release_notes
    release_notes=$(generate_release_notes "$latest_tag")

    echo -e "${BLUE}Release notes:${NC}"
    echo "$release_notes"
    echo ""

    # Confirm (skip if --yes flag provided)
    if [[ "$YES_FLAG" != true ]]; then
        read -rp "Proceed with release? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    # Update all version files
    echo ""
    update_all_versions "$new_version"

    # Commit version changes
    git add "$FRONTEND_PACKAGE_JSON" "$BACKEND_PYPROJECT" "$LIBS_PYPROJECT"
    git commit -m "chore: bump version to ${new_version#v}"

    # Create and push tag
    echo ""
    echo -e "${BLUE}Creating tag...${NC}"
    git tag -a "$new_version" -m "Release $new_version"

    echo -e "${BLUE}Pushing changes and tag...${NC}"
    git push origin HEAD
    git push origin "$new_version"

    # Create GitHub release
    echo -e "${BLUE}Creating GitHub release...${NC}"
    gh release create "$new_version" \
        --title "$new_version" \
        --notes "$release_notes" \
        --latest

    echo ""
    echo -e "${GREEN}✓ Release $new_version created successfully!${NC}"
    echo ""
    echo "The platform-autogpt-deploy-prod.yml workflow should now be triggered."
    echo "View releases: gh release list"
    echo "View workflow: gh run list --workflow=platform-autogpt-deploy-prod.yml"
}

main "$@"
