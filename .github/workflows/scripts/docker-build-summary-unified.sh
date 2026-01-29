#!/usr/bin/env bash
#
# docker-build-summary-unified.sh - Generate Docker build summary for GitHub Actions
#
# This is a consolidated, production-ready replacement for:
#   - docker-ci-summary.sh
#   - docker-release-summary.sh
#
# Usage: docker-build-summary-unified.sh [ci|release]
#
# Required Environment Variables (All Modes):
#   IMAGE_NAME         - Docker image name with tag
#   current_ref        - Current git ref (branch/tag)
#   commit_hash        - Full commit SHA
#   repository         - Repository name
#   source_url         - URL to source commit
#   github_context_json - GitHub context JSON
#   vars_json          - Workflow vars context
#   job_env_json       - Job environment JSON
#
# CI Mode Additional Variables:
#   base_branch        - Base branch name
#   build_type         - Build type label
#   compare_url_template - URL template for comparisons
#   event_name         - GitHub event name
#   event_ref          - Event ref
#   push_forced_label  - Forced push indicator (optional)
#   new_commits_json   - JSON array of new commits
#
# Release Mode Additional Variables:
#   ref_type           - Ref type (tag/branch)
#   event_name         - GitHub event name
#   inputs_no_cache    - No-cache build parameter
#
# Optional Variables:
#   DEBUG              - Set to "true" for verbose output
#   DRY_RUN            - Set to "true" to validate without generating output
#
# Exit Codes:
#   0 - Success
#   1 - General error
#   2 - Missing dependency
#   3 - Invalid arguments or missing required variables
#   4 - Docker command failed
#
# Examples:
#   docker-build-summary-unified.sh ci
#   docker-build-summary-unified.sh release
#   DEBUG=true docker-build-summary-unified.sh ci
#
# Author: Auto-GPT Team
# Version: 2.0.0
# License: Polyform Shield
#

set -Eeuo pipefail

#-----------------------------------------------------------
# Constants
#-----------------------------------------------------------

readonly SCRIPT_VERSION="2.0.0"

# Declare and assign separately to avoid masking return values (SC2155)
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_NAME

# Required external commands
readonly REQUIRED_DEPS=(docker jq base64 column cut sed grep)

# Common required variables for all modes
readonly REQUIRED_VARS_COMMON=(
    IMAGE_NAME
    current_ref
    commit_hash
    repository
    source_url
    github_context_json
    vars_json
    job_env_json
)

# CI mode specific required variables
readonly REQUIRED_VARS_CI=(
    base_branch
    build_type
    compare_url_template
    event_name
    event_ref
    new_commits_json
)

# Release mode specific required variables
readonly REQUIRED_VARS_RELEASE=(
    ref_type
    event_name
    inputs_no_cache
)

#-----------------------------------------------------------
# Global Variables
#-----------------------------------------------------------

# Mode selection (ci or release)
MODE=""

# Cached metadata
CACHED_META=""

#-----------------------------------------------------------
# Utility Functions
#-----------------------------------------------------------

# Print error message to stderr
error() {
    printf "[ERROR] %s\n" "$*" >&2
}

# Print info message to stderr
info() {
    printf "[INFO] %s\n" "$*" >&2
}

# Print debug message to stderr if DEBUG is set
debug() {
    [[ "${DEBUG:-}" == "true" ]] && printf "[DEBUG] %s\n" "$*" >&2 || true
}

# Error handler for ERR trap
error_handler() {
    local exit_code=$1
    local line_number=$2
    error "Script failed at line $line_number with exit code $exit_code"
    exit "$exit_code"
}

# Cleanup handler for EXIT trap
cleanup() {
    debug "Cleanup completed"
}

# Display usage information
usage() {
    cat << 'EOF'
Usage: docker-build-summary-unified.sh [OPTIONS] MODE

Generate Docker build summary for GitHub Actions workflows.

MODES:
    ci          Generate CI build summary
    release     Generate release build summary

OPTIONS:
    -h, --help  Show this help message
    -v, --version Show script version

ENVIRONMENT VARIABLES:
    DEBUG=true      Enable verbose debug output
    DRY_RUN=true    Validate inputs without generating output

REQUIRED VARIABLES:
    See script header for complete list of required environment variables.

EXIT CODES:
    0    Success
    1    General error
    2    Missing dependency
    3    Invalid arguments or missing required variables
    4    Docker command failed

EXAMPLES:
    # Generate CI summary
    docker-build-summary-unified.sh ci

    # Generate release summary with debug output
    DEBUG=true docker-build-summary-unified.sh release

    # Dry run to validate environment
    DRY_RUN=true docker-build-summary-unified.sh ci

EOF
}

#-----------------------------------------------------------
# Validation Functions
#-----------------------------------------------------------

# Check if required external dependencies are available
check_dependencies() {
    debug "Checking dependencies: ${REQUIRED_DEPS[*]}"

    local missing_deps=()
    local dep

    for dep in "${REQUIRED_DEPS[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if (( ${#missing_deps[@]} > 0 )); then
        error "Missing required dependencies: ${missing_deps[*]}"
        error "Please install missing dependencies and try again"
        exit 2
    fi

    debug "All dependencies found"
}

# Validate required environment variables
validate_variables() {
    debug "Validating environment variables"

    local missing_vars=()
    local var

    for var in "$@"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if (( ${#missing_vars[@]} > 0 )); then
        error "Missing required environment variables:"
        printf "  - %s\n" "${missing_vars[@]}" >&2
        error "See --help for required variables per mode"
        exit 3
    fi

    debug "All required variables present"
}

#-----------------------------------------------------------
# Docker Metadata Functions
#-----------------------------------------------------------

# Get and cache Docker image metadata
get_image_metadata() {
    if [[ -z "$CACHED_META" ]]; then
        debug "Fetching Docker image metadata for: $IMAGE_NAME"

        if ! CACHED_META=$(docker image inspect "$IMAGE_NAME" 2>&1); then
            error "Failed to inspect Docker image: $IMAGE_NAME"
            error "$CACHED_META"
            exit 4
        fi

        # Extract first element from array
        if ! CACHED_META=$(jq -r '.[0]' <<< "$CACHED_META" 2>&1); then
            error "Failed to parse Docker metadata JSON"
            error "$CACHED_META"
            exit 4
        fi

        debug "Docker metadata cached successfully"
    fi

    printf "%s" "$CACHED_META"
}

# Calculate and format image size in MB
get_image_size_mb() {
    local meta
    meta="$(get_image_metadata)"

    local size_bytes
    if ! size_bytes=$(jq -r .Size <<< "$meta" 2>&1); then
        error "Failed to extract image size from metadata"
        return 1
    fi

    # Convert to MB
    printf "%d" "$((size_bytes / 10**6))"
}

# Get repository tags as Markdown list
get_repo_tags() {
    local meta
    meta="$(get_image_metadata)"

    if ! jq -r '.RepoTags | map("* `\(.)`") | join("\n")' <<< "$meta" 2>&1; then
        error "Failed to extract repository tags"
        return 1
    fi
}

#-----------------------------------------------------------
# Summary Section Functions
#-----------------------------------------------------------

# Generate random heredoc delimiter to prevent injection
generate_heredoc_delimiter() {
    # Use base64-encoded random data for unique delimiter
    # This prevents issues if variables contain "EOF"
    if command -v openssl &>/dev/null; then
        openssl rand -base64 12
    else
        dd if=/dev/urandom bs=15 count=1 status=none 2>/dev/null | base64
    fi
}

# Generate Docker layer history table
generate_layer_table() {
    debug "Generating layer history table"

    # Single sed call for all transformations (performance optimization)
    docker history --no-trunc \
        --format "{{.CreatedSince}}\t{{.Size}}\t\`{{.CreatedBy}}\`\t{{.Comment}}" \
        "$IMAGE_NAME" \
        | grep 'buildkit.dockerfile' \
        | cut -f-3 \
        | sed 's/ ago//; s/ # buildkit//; s/\$/\\$/g; s/|/\\|/g' \
        | column -t -s$'\t' -o' | ' \
        | sed 's/^/| /; s/$/ |/'
}

# Generate environment variables table
generate_env_table() {
    debug "Generating environment variables table"

    local meta
    meta="$(get_image_metadata)"

    jq -r '
        .Config.Env
        | map(
            split("=")
            | "\(.[0]) | `\(.[1] | gsub("\\s+"; " "))`"
        )
        | map("| \(.) |")
        | .[]
    ' <<< "$meta"
}

# Generate raw metadata section
generate_raw_metadata() {
    debug "Generating raw metadata section"

    local meta
    meta="$(get_image_metadata)"

    cat << 'EOF_SECTION'
<details>
<summary>Raw metadata</summary>

```JSON
EOF_SECTION
    printf "%s\n" "$meta"
    cat << 'EOF_SECTION'
```
</details>
EOF_SECTION
}

# Generate job environment section (common to both modes)
generate_job_environment() {
    debug "Generating job environment section"

    cat << 'EOF_SECTION'
### Job environment

#### `vars` context:
```JSON
EOF_SECTION
    printf "%s\n" "$vars_json"
    cat << 'EOF_SECTION'
```

#### `env` context:
```JSON
EOF_SECTION
    printf "%s\n" "$job_env_json"
    cat << 'EOF_SECTION'
```
EOF_SECTION
}

#-----------------------------------------------------------
# CI Mode Functions
#-----------------------------------------------------------

generate_ci_summary() {
    info "Generating CI build summary"

    # Validate CI-specific variables
    validate_variables "${REQUIRED_VARS_CI[@]}"

    # Generate dynamic URLs
    local head_compare_url
    local ref_compare_url

    head_compare_url=$(sed "s/{base}/$base_branch/; s/{head}/$current_ref/" <<< "$compare_url_template")
    ref_compare_url=$(sed "s/{base}/$base_branch/; s/{head}/$commit_hash/" <<< "$compare_url_template")

    # Get image data
    local image_size_mb
    image_size_mb=$(get_image_size_mb)

    local repo_tags
    repo_tags=$(get_repo_tags)

    local layer_table
    layer_table=$(generate_layer_table)

    local env_table
    env_table=$(generate_env_table)

    # Generate unique heredoc delimiter
    # Note: EOF_DELIMITER is used as the heredoc terminator below (cat << EOF_DELIMITER)
    # ShellCheck doesn't recognize this usage pattern, hence the disable directive
    # shellcheck disable=SC2034
    local EOF_DELIMITER
    EOF_DELIMITER=$(generate_heredoc_delimiter)

    # Generate summary (use unquoted delimiter for variable expansion)
    cat << EOF_DELIMITER
# Docker Build summary 🔨

**Source:** branch \`$current_ref\` -> [$repository@\`${commit_hash:0:7}\`]($source_url)

**Build type:** \`$build_type\`

**Image size:** ${image_size_mb}MB

## Image details

**Tags:**
$repo_tags

<details>
<summary><h3>Layers</h3></summary>

|    Age    |  Size  | Created by instruction |
| --------- | ------ | ---------------------- |
$layer_table
</details>

<details>
<summary><h3>ENV</h3></summary>

| Variable | Value    |
| -------- | -------- |
$env_table
</details>

$(generate_raw_metadata)

## Build details
**Build trigger:** ${push_forced_label:-} $event_name \`$event_ref\`

<details>
<summary><code>github</code> context</summary>

\`\`\`JSON
$github_context_json
\`\`\`
</details>

### Source
**HEAD:** [$repository@\`${commit_hash:0:7}\`]($source_url) on branch [$current_ref]($ref_compare_url)

**Diff with previous HEAD:** $head_compare_url

#### New commits
$(jq -r 'map([
    "**Commit [`\(.id[0:7])`](\(.url)) by \(if .author.username then "@"+.author.username else .author.name end):**",
    .message,
    (if .committer.name != .author.name then "\n> <sub>**Committer:** \(.committer.name) <\(.committer.email)></sub>" else "" end),
    "<sub>**Timestamp:** \(.timestamp)</sub>"
] | map("> \(.)\n") | join("")) | join("\n")' <<< "$new_commits_json")

$(generate_job_environment)

EOF_DELIMITER
}

#-----------------------------------------------------------
# Release Mode Functions
#-----------------------------------------------------------

generate_release_summary() {
    info "Generating release build summary"

    # Validate release-specific variables
    validate_variables "${REQUIRED_VARS_RELEASE[@]}"

    # Get image data
    local image_size_mb
    image_size_mb=$(get_image_size_mb)

    local repo_tags
    repo_tags=$(get_repo_tags)

    local layer_table
    layer_table=$(generate_layer_table)

    local env_table
    env_table=$(generate_env_table)

    # Generate unique heredoc delimiter
    # Note: EOF_DELIMITER is used as the heredoc terminator below (cat << EOF_DELIMITER)
    # ShellCheck doesn't recognize this usage pattern, hence the disable directive
    # shellcheck disable=SC2034
    local EOF_DELIMITER
    EOF_DELIMITER=$(generate_heredoc_delimiter)

    # Generate summary (use unquoted delimiter for variable expansion)
    cat << EOF_DELIMITER
# Docker Release Build summary 🚀🔨

**Source:** $ref_type \`$current_ref\` -> [$repository@\`${commit_hash:0:7}\`]($source_url)

**Image size:** ${image_size_mb}MB

## Image details

**Tags:**
$repo_tags

<details>
<summary><h3>Layers</h3></summary>

|    Age    |  Size  | Created by instruction |
| --------- | ------ | ---------------------- |
$layer_table
</details>

<details>
<summary><h3>ENV</h3></summary>

| Variable | Value    |
| -------- | -------- |
$env_table
</details>

$(generate_raw_metadata)

## Build details
**Build trigger:** $event_name \`$current_ref\`

| Parameter      | Value        |
| -------------- | ------------ |
| \`no_cache\`   | \`$inputs_no_cache\` |

<details>
<summary><code>github</code> context</summary>

\`\`\`JSON
$github_context_json
\`\`\`
</details>

$(generate_job_environment)

EOF_DELIMITER
}

#-----------------------------------------------------------
# Main Function
#-----------------------------------------------------------

main() {
    # Parse arguments
    while (( $# > 0 )); do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                printf "%s version %s\n" "$SCRIPT_NAME" "$SCRIPT_VERSION"
                exit 0
                ;;
            ci|release)
                MODE="$1"
                shift
                ;;
            *)
                error "Unknown argument: $1"
                usage
                exit 3
                ;;
        esac
    done

    # Validate mode was provided
    if [[ -z "$MODE" ]]; then
        error "Mode (ci|release) is required"
        usage
        exit 3
    fi

    # Enable debug output if requested
    if [[ "${DEBUG:-}" == "true" ]]; then
        debug "Debug mode enabled"
        debug "Script: $SCRIPT_NAME v$SCRIPT_VERSION"
        debug "Mode: $MODE"
    fi

    # Check dependencies
    check_dependencies

    # Validate common variables
    validate_variables "${REQUIRED_VARS_COMMON[@]}"

    # Dry run mode - exit after validation
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        info "Dry run mode - validation successful"
        exit 0
    fi

    # Generate appropriate summary
    case "$MODE" in
        ci)
            generate_ci_summary
            ;;
        release)
            generate_release_summary
            ;;
        *)
            error "Invalid mode: $MODE"
            exit 3
            ;;
    esac

    debug "Summary generated successfully"
}

#-----------------------------------------------------------
# Script Entry Point
#-----------------------------------------------------------

# Set up error handling
trap 'error_handler $? $LINENO' ERR
trap 'cleanup' EXIT

# Run main function
main "$@"
