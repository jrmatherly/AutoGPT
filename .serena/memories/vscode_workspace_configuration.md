# VS Code Workspace Configuration

**Last Updated:** 2026-01-30
**Status:** ✅ Production-Ready

## Overview

The AutoGPT project uses a multi-root VS Code workspace file for optimal development experience with proper Python interpreter isolation and per-folder settings.

## Workspace File Location

**File:** `AutoGPT.code-workspace` (project root)
**Previous Location:** `.vscode/all-projects.code-workspace` (deprecated, removed)

### Why at Project Root?

When opening `/Users/jason/dev/AutoGPT` as a folder, VS Code:
- Auto-detects `AutoGPT.code-workspace`
- Prompts to open the workspace file
- Correctly resolves relative paths from workspace file location

Previous location in `.vscode/` caused path resolution issues where `[root]` folder showed as `~/dev` instead of `~/dev/AutoGPT`.

## Workspace Structure

```json
{
  "folders": [
    { "name": "frontend", "path": "autogpt_platform/frontend" },
    { "name": "backend", "path": "autogpt_platform/backend" },
    { "name": "lib", "path": "autogpt_platform/autogpt_libs" },
    { "name": "docs", "path": "docs" },
    { "name": "[root]", "path": "." }
  ]
}
```

**All paths are relative to workspace file location** (project root).

## Per-Folder Python Environments

### Backend Folder
- Python interpreter: `.venv/bin/python` (Python 3.13.11 via mise)
- Formatter: Ruff
- Testing: pytest with snapshot support
- Linter: Ruff with `--target-version=py310`

### Lib Folder
- Python interpreter: `.venv/bin/python`
- Same configuration as backend

### Frontend/Docs/Root Folders
- No Python interpreter needed (TypeScript/Node.js project)
- Showing homebrew Python (3.14.2) is cosmetic only

## Launch Configurations

Located in `.vscode/launch.json`:

### Frontend Debugging
- Uses `mise run frontend` command
- Working directory: `autogpt_platform/`
- Supports server-side and client-side debugging

### Backend Debugging
- Module: `backend.app`
- Python path: Explicit `.venv/bin/python`
- Working directory: `autogpt_platform/backend/`
- Env file: `autogpt_platform/backend/.env`

## Integration with Other Tools

### Branchlet (Git Worktrees)
```json
{
  "worktreeCopyPatterns": [
    "AutoGPT.code-workspace",  // ✅ Workspace file copied to worktrees
    ".vscode/**"
  ]
}
```

### Mise Task Delegation
All mise tasks delegate from root `mise.toml` → `autogpt_platform/mise.toml`:
- Developers can run `mise run <task>` from project root
- Tasks use `${workspaceFolder}` which resolves correctly
- No hardcoded paths dependent on workspace file location

### Drift Configuration
- `.driftignore` excludes `.vscode/` directory (not workspace file)
- Drift tasks accessible from project root via mise delegation

## Opening the Project

### Recommended Approach
```bash
# Option 1: Open workspace file directly
code ~/dev/AutoGPT/AutoGPT.code-workspace

# Option 2: Open folder, then accept workspace prompt
code ~/dev/AutoGPT
# Click "Open Workspace" when prompted
```

### From Terminal Alias
```bash
# Add to ~/.zshrc or ~/.bashrc
alias autogpt='code ~/dev/AutoGPT/AutoGPT.code-workspace'
```

## Validation Checklist

✅ Workspace file at project root (`AutoGPT.code-workspace`)
✅ All folder paths relative to workspace file location
✅ Backend Python interpreter properly configured (3.13.11)
✅ Launch configurations use `${workspaceFolder}` (dynamic)
✅ Branchlet copies workspace file to worktrees
✅ Mise tasks accessible from project root
✅ Drift tasks working via mise delegation
✅ Documentation updated (`docs/github/VSCODE_WORKFLOW_WARNINGS.md`)
✅ No hardcoded paths dependent on workspace file location

## Troubleshooting

### [root] Shows Wrong Directory
**Symptom:** [root] shows `~/dev` instead of `~/dev/AutoGPT`

**Cause:** Workspace file in `.vscode/` with path `".."` resolves incorrectly

**Solution:** ✅ Fixed - workspace file moved to project root with path `"."`

### Python Interpreter Not Found
**Symptom:** Backend shows wrong Python version

**Cause:** Workspace not opened (opened as folder instead)

**Solution:** Click "Open Workspace" when prompted, or open workspace file directly

### Mise Tasks Not Available from Root
**Symptom:** `mise run drift:status` not found when in project root

**Cause:** Missing task delegation in root `mise.toml`

**Solution:** ✅ Fixed - added drift and deps tasks to root mise.toml

## Related Documentation

- `docs/github/VSCODE_WORKFLOW_WARNINGS.md` - VS Code warning suppression
- `.vscode/settings.json` - Global workspace settings
- `.vscode/launch.json` - Debug configurations
- `mise.toml` - Root task delegation
- `.branchlet.json` - Worktree configuration