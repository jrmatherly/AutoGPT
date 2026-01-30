#!/usr/bin/env bash
# =============================================================================
# AutoGPT Platform Release Script (Production-Hardened)
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
#   mise run release --dry-run    # Show what would be done without executing
# =============================================================================

set -euo pipefail

# Determine script and repository root (absolute paths)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"

# Platform detection for sed compatibility
UNAME_S="$(uname -s)"

# Colors - only use in interactive terminal
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

# Flags
YES_FLAG=false
DRY_RUN=false
BACKUP_DIR=""

# Version file paths (absolute)
FRONTEND_PACKAGE_JSON="$REPO_ROOT/autogpt_platform/frontend/package.json"
BACKEND_PYPROJECT="$REPO_ROOT/autogpt_platform/backend/pyproject.toml"
LIBS_PYPROJECT="$REPO_ROOT/autogpt_platform/autogpt_libs/pyproject.toml"

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 && -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
        echo -e "${RED}Error occurred. Restoring from backup...${NC}" >&2
        restore_version_files "$BACKUP_DIR"
        rm -rf "$BACKUP_DIR"
    fi
    exit "$exit_code"
}

# Set up error trapping
trap 'cleanup' ERR EXIT

# Validate required dependencies
validate_dependencies() {
    local missing=()

    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v node >/dev/null 2>&1 || missing+=("node")
    command -v gh >/dev/null 2>&1 || missing+=("gh")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Missing required commands: ${missing[*]}${NC}" >&2
        echo "Install missing tools and try again." >&2
        exit 1
    fi
}

# Backup all version files atomically
backup_version_files() {
    local backup_dir
    backup_dir=$(mktemp -d) || {
        echo -e "${RED}Failed to create backup directory${NC}" >&2
        return 1
    }

    [[ -f "$FRONTEND_PACKAGE_JSON" ]] && cp "$FRONTEND_PACKAGE_JSON" "$backup_dir/package.json" 2>/dev/null
    [[ -f "$BACKEND_PYPROJECT" ]] && cp "$BACKEND_PYPROJECT" "$backup_dir/backend-pyproject.toml" 2>/dev/null
    [[ -f "$LIBS_PYPROJECT" ]] && cp "$LIBS_PYPROJECT" "$backup_dir/libs-pyproject.toml" 2>/dev/null

    echo "$backup_dir"
}

# Restore from backup
restore_version_files() {
    local backup_dir="$1"
    if [[ -d "$backup_dir" ]]; then
        [[ -f "$backup_dir/package.json" ]] && cp "$backup_dir/package.json" "$FRONTEND_PACKAGE_JSON" 2>/dev/null
        [[ -f "$backup_dir/backend-pyproject.toml" ]] && cp "$backup_dir/backend-pyproject.toml" "$BACKEND_PYPROJECT" 2>/dev/null
        [[ -f "$backup_dir/libs-pyproject.toml" ]] && cp "$backup_dir/libs-pyproject.toml" "$LIBS_PYPROJECT" 2>/dev/null
        echo -e "${YELLOW}Restored version files from backup${NC}" >&2
    fi
}

# Validate semantic version format
validate_version() {
    local version="${1#v}"

    # Must match semver format
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Invalid version format: $version${NC}" >&2
        echo "Expected format: X.Y.Z (e.g., 1.2.3)" >&2
        return 1
    fi

    # Parse components
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"

    # Validate numeric ranges (prevent overflow)
    if (( major > 999 || minor > 999 || patch > 9999 )); then
        echo -e "${RED}Version numbers too large: $version${NC}" >&2
        return 1
    fi

    # Ensure no leading zeros (except for 0 itself)
    if [[ "$major" =~ ^0[0-9]+ ]] || [[ "$minor" =~ ^0[0-9]+ ]] || [[ "$patch" =~ ^0[0-9]+ ]]; then
        echo -e "${RED}Version numbers cannot have leading zeros: $version${NC}" >&2
        return 1
    fi

    return 0
}

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

# Get version from backend pyproject.toml (only uncommented lines)
get_backend_version() {
    if [[ ! -f "$BACKEND_PYPROJECT" ]]; then
        echo "0.0.0"
        return
    fi
    grep -m1 '^version[[:space:]]*=' "$BACKEND_PYPROJECT" | \
        sed 's/^version[[:space:]]*=[[:space:]]*"\(.*\)"/\1/' || echo "0.0.0"
}

# Get version from libs pyproject.toml (only uncommented lines)
get_libs_version() {
    if [[ ! -f "$LIBS_PYPROJECT" ]]; then
        echo "0.0.0"
        return
    fi
    grep -m1 '^version[[:space:]]*=' "$LIBS_PYPROJECT" | \
        sed 's/^version[[:space:]]*=[[:space:]]*"\(.*\)"/\1/' || echo "0.0.0"
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

# Portable version comparison (no sort -V)
version_greater_or_equal() {
    local ver1="$1"
    local ver2="$2"

    # Return 0 (true) if ver1 >= ver2
    printf '%s\n%s\n' "$ver1" "$ver2" | sort -t. -k1,1n -k2,2n -k3,3n | head -n1 | grep -qx "$ver2"
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

    # Find highest version (portable)
    local highest="$frontend"
    if version_greater_or_equal "$backend" "$highest"; then
        highest="$backend"
    fi
    if version_greater_or_equal "$libs" "$highest"; then
        highest="$libs"
    fi

    echo -e "${BLUE}Recommended: Synchronize to v${highest} (highest current version)${NC}"
    echo "Alternatively: Start fresh at v1.0.0"
    echo ""

    read -rp "Synchronize to v${highest}? [Y/n] " sync_choice
    if [[ "$sync_choice" =~ ^[Nn]$ ]]; then
        read -rp "Enter desired version (e.g., 1.0.0): " custom_version
        local result="v${custom_version#v}"
        validate_version "$result" || exit 1
        echo "$result"
    else
        echo "v${highest}"
    fi
}

# Parse version into components
parse_version() {
    local version="${1#v}"
    local major minor patch

    IFS='.' read -r major minor patch <<< "$version"

    # Validate all components exist
    if [[ -z "$major" || -z "$minor" || -z "$patch" ]]; then
        echo -e "${RED}Invalid version format: $version${NC}" >&2
        return 1
    fi

    echo "$major $minor $patch"
}

# Increment version based on type
increment_version() {
    local current="$1"
    local type="${2:-patch}"

    read -r major minor patch <<< "$(parse_version "$current")" || return 1

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

# Update frontend package.json version (injection-safe)
update_frontend_version() {
    local version="${1#v}"

    # Validate version format
    validate_version "v$version" || return 1

    if [[ ! -f "$FRONTEND_PACKAGE_JSON" ]]; then
        echo -e "${RED}Error: $FRONTEND_PACKAGE_JSON not found${NC}" >&2
        return 1
    fi

    # Use safer approach with proper escaping (pass version as argument)
    node -e '
        const fs = require("fs");
        const pkg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
        pkg.version = process.argv[2];
        fs.writeFileSync(process.argv[1], JSON.stringify(pkg, null, 2) + "\n");
    ' "$FRONTEND_PACKAGE_JSON" "$version" || {
        echo -e "${RED}Failed to update package.json${NC}" >&2
        return 1
    }

    echo -e "${BLUE}  ✓ Updated frontend/package.json → ${version}${NC}"
}

# Update backend pyproject.toml version (platform-safe sed)
update_backend_version() {
    local version="${1#v}"

    validate_version "v$version" || return 1

    if [[ ! -f "$BACKEND_PYPROJECT" ]]; then
        echo -e "${RED}Error: $BACKEND_PYPROJECT not found${NC}" >&2
        return 1
    fi

    # Platform-specific sed handling
    case "$UNAME_S" in
        Darwin*|*BSD*)
            sed -i '' "s/^version[[:space:]]*=.*/version = \"$version\"/" "$BACKEND_PYPROJECT" || {
                echo -e "${RED}Failed to update $BACKEND_PYPROJECT${NC}" >&2
                return 1
            }
            ;;
        *)
            sed -i "s/^version[[:space:]]*=.*/version = \"$version\"/" "$BACKEND_PYPROJECT" || {
                echo -e "${RED}Failed to update $BACKEND_PYPROJECT${NC}" >&2
                return 1
            }
            ;;
    esac

    echo -e "${BLUE}  ✓ Updated backend/pyproject.toml → ${version}${NC}"
}

# Update libs pyproject.toml version (platform-safe sed)
update_libs_version() {
    local version="${1#v}"

    validate_version "v$version" || return 1

    if [[ ! -f "$LIBS_PYPROJECT" ]]; then
        echo -e "${RED}Error: $LIBS_PYPROJECT not found${NC}" >&2
        return 1
    fi

    # Platform-specific sed handling
    case "$UNAME_S" in
        Darwin*|*BSD*)
            sed -i '' "s/^version[[:space:]]*=.*/version = \"$version\"/" "$LIBS_PYPROJECT" || {
                echo -e "${RED}Failed to update $LIBS_PYPROJECT${NC}" >&2
                return 1
            }
            ;;
        *)
            sed -i "s/^version[[:space:]]*=.*/version = \"$version\"/" "$LIBS_PYPROJECT" || {
                echo -e "${RED}Failed to update $LIBS_PYPROJECT${NC}" >&2
                return 1
            }
            ;;
    esac

    echo -e "${BLUE}  ✓ Updated autogpt_libs/pyproject.toml → ${version}${NC}"
}

# Update all version files atomically with backup/restore
update_all_versions() {
    local version="$1"

    # Create backup before any modifications
    BACKUP_DIR=$(backup_version_files) || {
        echo -e "${RED}Failed to create backup${NC}" >&2
        return 1
    }

    echo -e "${BLUE}Updating all version files...${NC}"

    # Update files (if any fail, cleanup trap will restore)
    update_frontend_version "$version" || return 1
    update_backend_version "$version" || return 1
    update_libs_version "$version" || return 1

    # Success - remove backup
    rm -rf "$BACKUP_DIR"
    BACKUP_DIR=""
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
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                input="$1"
                shift
                ;;
        esac
    done

    # Change to repository root
    cd "$REPO_ROOT" || {
        echo -e "${RED}Failed to change to repository root: $REPO_ROOT${NC}" >&2
        exit 1
    }

    # Validate dependencies
    validate_dependencies

    # Ensure we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}" >&2
        exit 1
    fi

    # Ensure working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        echo -e "${RED}Error: Working directory is not clean. Commit or stash changes first.${NC}" >&2
        exit 1
    fi

    # Ensure gh CLI is authenticated
    if ! gh auth status >/dev/null 2>&1; then
        echo -e "${RED}Error: gh CLI not authenticated. Run 'gh auth login' first.${NC}" >&2
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
        git add -- "$FRONTEND_PACKAGE_JSON" "$BACKEND_PYPROJECT" "$LIBS_PYPROJECT"
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
                validate_version "$new_version" || exit 1
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
        validate_version "$new_version" || exit 1
    else
        echo -e "${RED}Invalid version format: $input${NC}"
        echo "Use: vX.Y.Z, major, minor, or patch"
        exit 1
    fi

    # Check if tag already exists
    if git rev-parse "$new_version" >/dev/null 2>&1; then
        echo -e "${RED}Error: Tag $new_version already exists${NC}" >&2
        echo -e "${YELLOW}Use 'git tag -d $new_version' to delete locally if needed${NC}" >&2
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

    # Dry-run mode
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}DRY RUN - Would perform:${NC}"
        echo "  1. Update version files to $new_version"
        echo "  2. Create commit: chore: bump version to ${new_version#v}"
        echo "  3. Create tag: $new_version"
        echo "  4. Push to origin"
        echo "  5. Create GitHub release"
        exit 0
    fi

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
    git add -- "$FRONTEND_PACKAGE_JSON" "$BACKEND_PYPROJECT" "$LIBS_PYPROJECT"
    git commit -m "chore: bump version to ${new_version#v}"

    # Create and push tag
    echo ""
    echo -e "${BLUE}Creating tag...${NC}"
    git tag -a "$new_version" -m "Release $new_version"

    echo -e "${BLUE}Pushing changes and tag...${NC}"
    if ! git push origin HEAD; then
        echo -e "${RED}Failed to push commit to remote${NC}" >&2
        echo -e "${YELLOW}You can manually push later with: git push origin HEAD${NC}" >&2
        exit 1
    fi

    if ! git push origin "$new_version"; then
        echo -e "${RED}Failed to push tag to remote${NC}" >&2
        echo -e "${YELLOW}You can manually push later with: git push origin $new_version${NC}" >&2
        exit 1
    fi

    # Create GitHub release
    echo -e "${BLUE}Creating GitHub release...${NC}"
    if ! gh release create "$new_version" \
        --title "$new_version" \
        --notes "$release_notes" \
        --latest; then
        echo -e "${RED}Failed to create GitHub release${NC}" >&2
        echo -e "${YELLOW}Tag $new_version was pushed successfully${NC}" >&2
        echo -e "${YELLOW}Create release manually with: gh release create $new_version${NC}" >&2
        exit 1
    fi

    echo ""
    echo -e "${GREEN}✓ Release $new_version created successfully!${NC}"
    echo ""
    echo "The platform-autogpt-deploy-prod.yml workflow should now be triggered."
    echo "View releases: gh release list"
    echo "View workflow: gh run list --workflow=platform-autogpt-deploy-prod.yml"
}

main "$@"
