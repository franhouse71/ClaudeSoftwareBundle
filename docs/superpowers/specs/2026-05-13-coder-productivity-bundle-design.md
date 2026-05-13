# Coder Productivity Bundle — Design Spec
**Date:** 2026-05-13  
**Status:** v1 approved

---

## Goal

A one-command Windows installer that sets up a complete, opinionated coding environment for anyone — from beginners to experienced developers. Minimum friction, maximum functionality.

---

## Distribution

**Delivery:** Single PowerShell one-liner the user pastes into a terminal:
```powershell
irm https://raw.githubusercontent.com/yourname/ClaudeSoftwareBundle/main/install.ps1 | iex
```

**Source:** GitHub repository (`ClaudeSoftwareBundle/`). Easy to update — editing the script on GitHub instantly updates what all future installs receive.

**Future (v2):** GitHub Pages landing page with a "Copy install command" button.

---

## Repository Structure

```
ClaudeSoftwareBundle/
├── install.ps1          ← main installer script
├── assets/
│   └── MyShortCuts.ahk  ← bundled AHK script
└── README.md            ← share-ready one-liner command
```

---

## What Gets Installed (v1)

| # | Tool | Method | Purpose |
|---|------|--------|---------|
| 1 | Windows Terminal | winget | Better terminal experience |
| 2 | Git | winget | Version control, required by Claude Code |
| 3 | AutoHotkey v2 | winget | Keyboard shortcuts engine |
| 4 | VS Code | winget | Code editor |
| 5 | uv | astral.sh script | Python version + package management |
| 6 | Claude Code CLI | npm (via Node) | AI coding assistant |
| 7 | OpenWhisper | openwhispr.com installer | Voice-to-text input |
| 8 | VS Code: Python extension | `code --install-extension` | Python language support |
| 9 | VS Code: GitLens | `code --install-extension` | Git history in editor |
| 10 | AHK script + startup | file copy + registry | Numpad1 → colored terminal tab running Claude |

**Not automated (user does manually):** Claude Code authentication (Claude's own auth flow handles this well).

---

## Script Architecture

`install.ps1` is modular — each tool is its own function with a consistent signature:

```
Check if installed → skip with ⏭️ → install if missing → log result
```

Adding a new tool in the future = adding one new function + one new call. No restructuring needed.

**Script flow:**
1. Print welcome banner
2. Check/fix PowerShell execution policy
3. Ensure winget is available
4. Run each install function in order
5. Copy `MyShortCuts.ahk` to `Documents/AutoHotkey/` and register for Windows startup
6. Print final summary
7. Open Claude Code for the user to authenticate

---

## Error Handling

- Failures in one step do not stop the rest of the script
- Summary uses color-coded output:
  - ✅ Green — installed successfully
  - ⏭️ Grey — already installed, skipped
  - ⚠️ Yellow — failed, with a plain-language instruction for the user
- Two Windows blockers handled automatically:
  - Execution policy bypassed in the one-liner command
  - Missing winget → clear message to install "App Installer" from Microsoft Store

---

## Future Additions (v2+)

- Claude Code skills
- MCP servers
- Updated AHK scripts
- GitHub Pages landing page with copy button
- Additional tools as needed

The modular script design means all of these are additive — no rewrites required.

---

## Testing

- **Smoke test:** Run on your own machine — tools already installed should all be skipped (grey), confirming detection logic works.
- **Real test:** Run on a fresh machine or a friend's computer. The install summary is the test output.
Potentially make a Virual Machine for checking if it works on a fresh machine