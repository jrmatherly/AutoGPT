# VS Code Workspace Configuration

## Workspace File

**Location:** `AutoGPT.code-workspace` (project root)

When opening the project folder, VS Code auto-detects this workspace file.

## Structure

```json
{
  "folders": [
    { "name": "frontend", "path": "autogpt_platform/frontend" },
    { "name": "backend", "path": "autogpt_platform/backend" },
    { "name": "libs", "path": "autogpt_platform/autogpt_libs" },
    { "name": "[root]", "path": "." }
  ]
}
```

## Python Interpreters

Each Python folder has isolated interpreter settings:
- Backend: `autogpt_platform/backend/.vscode/settings.json`
- Libs: `autogpt_platform/autogpt_libs/.vscode/settings.json`

**Note:** Use mise-managed Python for consistency with CI.
