# Coder Productivity Bundle — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single PowerShell installer that sets up a complete coding environment (Windows Terminal, Git, AutoHotkey, VS Code, Node.js, uv, Claude Code CLI, OpenWhispr, VS Code extensions, AHK script) with one pasted command.

**Architecture:** A modular `install.ps1` where each tool is its own function that checks for existing installation before acting — safe to run multiple times. Assets (AHK script) are hosted on GitHub and downloaded at install time. OpenWhispr always fetches the latest release dynamically via GitHub API.

**Tech Stack:** PowerShell 5.1+, winget, GitHub raw URLs, GitHub Releases API

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `install.ps1` | Create | Main installer — all install logic, built up task by task |
| `assets/MyShortCuts.ahk` | Create | AHK script bundled for download during install |
| `README.md` | Create | One-liner install command to share with others |

---

### Task 1: Initialize git repo and README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Initialize git repo**

```bash
cd "C:\Users\franl\Desktop\Archivos-python\Scripts-with-Claude-code\ClaudeSoftwareBundle"
git init
git branch -M main
```

Expected output: `Initialized empty Git repository in .../ClaudeSoftwareBundle/.git/`

- [ ] **Step 2: Create README.md**

Create the file with this exact content:

```markdown
# Claude Productivity Bundle

One-command setup for a complete AI-powered coding environment on Windows.

## Install

Open PowerShell and paste:

powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/ClaudeSoftwareBundle/main/install.ps1 | iex"

## What gets installed

| Tool | Purpose |
|------|---------|
| Windows Terminal | Better terminal experience |
| Git | Version control |
| AutoHotkey v2 | Keyboard shortcuts |
| VS Code | Code editor |
| Node.js | Required for Claude Code |
| uv | Python version + package management |
| Claude Code CLI | AI coding assistant |
| OpenWhispr | Voice-to-text input |
| VS Code: Python extension | Python language support |
| VS Code: GitLens | Git history in editor |
| AHK Script | Numpad1 opens a colored terminal tab running Claude |

## After install

1. Open a new terminal and run: `claude`
2. Sign in with your Claude Pro/Max account
3. Press Numpad1 to open a colored terminal tab ready to code
```

- [ ] **Step 3: Commit**

```bash
git add README.md docs/
git commit -m "feat: initial project structure, spec, and plan"
```

---

### Task 2: Bundle the AHK script

**Files:**
- Create: `assets/MyShortCuts.ahk`

- [ ] **Step 1: Create assets directory and copy AHK script**

```bash
mkdir assets
cp "C:\Users\franl\Documents\AutoHotkey\MyShortCuts.ahk" "C:\Users\franl\Desktop\Archivos-python\Scripts-with-Claude-code\ClaudeSoftwareBundle\assets\MyShortCuts.ahk"
```

- [ ] **Step 2: Verify it copied correctly**

Open `assets/MyShortCuts.ahk` and confirm it starts with `#Requires AutoHotkey v2.0`

- [ ] **Step 3: Commit**

```bash
git add assets/MyShortCuts.ahk
git commit -m "feat: bundle AHK script in assets"
```

---

### Task 3: Create install.ps1 scaffold

**Files:**
- Create: `install.ps1`

- [ ] **Step 1: Create install.ps1 with this exact content**

```powershell
# Claude Productivity Bundle Installer
# Source: https://github.com/YOUR_GITHUB_USERNAME/ClaudeSoftwareBundle

$GITHUB_RAW = "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/ClaudeSoftwareBundle/main"
$script:summary = @()

function Write-Banner {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   Claude Productivity Bundle" -ForegroundColor Cyan
    Write-Host "   Setting up your coding env..." -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "-> $Message" -ForegroundColor Cyan
}

function Add-Result {
    param([string]$Tool, [string]$Status, [string]$Hint = "")
    $script:summary += [PSCustomObject]@{ Tool = $Tool; Status = $Status; Hint = $Hint }
}

function Write-Success { param([string]$Tool); Write-Host "  OK  $Tool installed" -ForegroundColor Green;  Add-Result $Tool "Installed" }
function Write-Skipped { param([string]$Tool); Write-Host "  --  $Tool already installed, skipping" -ForegroundColor Gray;   Add-Result $Tool "Skipped" }
function Write-Failed  { param([string]$Tool, [string]$Hint); Write-Host "  !!  $Tool failed -- $Hint" -ForegroundColor Yellow; Add-Result $Tool "Failed" $Hint }

function Refresh-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

function Show-Summary {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   Installation Summary" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    foreach ($item in $script:summary) {
        switch ($item.Status) {
            "Installed" { Write-Host "  OK  $($item.Tool)" -ForegroundColor Green }
            "Skipped"   { Write-Host "  --  $($item.Tool) (already installed)" -ForegroundColor Gray }
            "Failed"    { Write-Host "  !!  $($item.Tool) -- $($item.Hint)" -ForegroundColor Yellow }
        }
    }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Open a new terminal and run: claude" -ForegroundColor White
    Write-Host "  2. Sign in with your Claude Pro/Max account" -ForegroundColor White
    Write-Host "  3. Press Numpad1 to open a colored terminal tab" -ForegroundColor White
    Write-Host ""
    Write-Host "Happy coding!" -ForegroundColor Cyan
    Write-Host ""
}

# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
Show-Summary
```

- [ ] **Step 2: Run it to confirm no errors**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: Banner prints, empty summary prints, next steps show. No red errors.

- [ ] **Step 3: Commit**

```bash
git add install.ps1
git commit -m "feat: installer scaffold with banner, helpers, and summary"
```

---

### Task 4: Add winget check

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Ensure-Winget function before the Main section**

Insert this function before the `# ── Main` line:

```powershell
function Ensure-Winget {
    Write-Step "Checking winget (Windows Package Manager)..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Skipped "winget"
        return $true
    }
    Write-Host ""
    Write-Host "  !! winget not found." -ForegroundColor Yellow
    Write-Host "  -> Install 'App Installer' from the Microsoft Store, then re-run this script." -ForegroundColor Yellow
    Write-Host ""
    return $false
}
```

- [ ] **Step 2: Update the Main section to call it**

Replace the Main section with:

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: winget line shows `--  winget already installed, skipping` (since you have winget).

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add winget availability check"
```

---

### Task 5: Add Windows Terminal installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-WindowsTerminal function before the Main section**

```powershell
function Install-WindowsTerminal {
    Write-Step "Windows Terminal..."
    $list = winget list --id Microsoft.WindowsTerminal --exact --accept-source-agreements | Out-String
    if ($list -match "Microsoft.WindowsTerminal") { Write-Skipped "Windows Terminal"; return }
    try {
        winget install --id Microsoft.WindowsTerminal --exact --silent --accept-package-agreements --accept-source-agreements
        Write-Success "Windows Terminal"
    } catch {
        Write-Failed "Windows Terminal" "Run: winget install Microsoft.WindowsTerminal"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  Windows Terminal already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add Windows Terminal installer"
```

---

### Task 6: Add Git installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-Git function before the Main section**

```powershell
function Install-Git {
    Write-Step "Git..."
    if (Get-Command git -ErrorAction SilentlyContinue) { Write-Skipped "Git"; return }
    try {
        winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
        Refresh-Path
        Write-Success "Git"
    } catch {
        Write-Failed "Git" "Run: winget install Git.Git"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  Git already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add Git installer"
```

---

### Task 7: Add AutoHotkey v2 installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-AutoHotkey function before the Main section**

```powershell
function Install-AutoHotkey {
    Write-Step "AutoHotkey v2..."
    $ahkExe = "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"
    if (Test-Path $ahkExe) { Write-Skipped "AutoHotkey v2"; return }
    try {
        winget install --id AutoHotkey.AutoHotkey --exact --silent --accept-package-agreements --accept-source-agreements
        Write-Success "AutoHotkey v2"
    } catch {
        Write-Failed "AutoHotkey v2" "Run: winget install AutoHotkey.AutoHotkey"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  AutoHotkey v2 already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add AutoHotkey v2 installer"
```

---

### Task 8: Add VS Code installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-VSCode function before the Main section**

```powershell
function Install-VSCode {
    Write-Step "Visual Studio Code..."
    if (Get-Command code -ErrorAction SilentlyContinue) { Write-Skipped "VS Code"; return }
    try {
        winget install --id Microsoft.VisualStudioCode --exact --silent --accept-package-agreements --accept-source-agreements
        Refresh-Path
        Write-Success "VS Code"
    } catch {
        Write-Failed "VS Code" "Run: winget install Microsoft.VisualStudioCode"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  VS Code already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add VS Code installer"
```

---

### Task 9: Add Node.js installer

**Files:**
- Modify: `install.ps1`

Node.js is required for Claude Code CLI (installed via npm).

- [ ] **Step 1: Add Install-NodeJS function before the Main section**

```powershell
function Install-NodeJS {
    Write-Step "Node.js (LTS)..."
    if (Get-Command node -ErrorAction SilentlyContinue) { Write-Skipped "Node.js"; return }
    try {
        winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
        Refresh-Path
        Write-Success "Node.js"
    } catch {
        Write-Failed "Node.js" "Run: winget install OpenJS.NodeJS.LTS"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Install-NodeJS
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  Node.js already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add Node.js installer (required for Claude Code)"
```

---

### Task 10: Add uv installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-Uv function before the Main section**

```powershell
function Install-Uv {
    Write-Step "uv (Python manager)..."
    if (Get-Command uv -ErrorAction SilentlyContinue) { Write-Skipped "uv"; return }
    try {
        powershell -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
        Refresh-Path
        Write-Success "uv"
    } catch {
        Write-Failed "uv" "Visit https://astral.sh/uv to install manually"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Install-NodeJS
Install-Uv
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  uv already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add uv Python manager installer"
```

---

### Task 11: Add Claude Code CLI installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-ClaudeCode function before the Main section**

```powershell
function Install-ClaudeCode {
    Write-Step "Claude Code CLI..."
    if (Get-Command claude -ErrorAction SilentlyContinue) { Write-Skipped "Claude Code CLI"; return }
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Failed "Claude Code CLI" "npm not in PATH -- restart PowerShell and re-run this script"
        return
    }
    try {
        npm install -g @anthropic-ai/claude-code
        Refresh-Path
        Write-Success "Claude Code CLI"
    } catch {
        Write-Failed "Claude Code CLI" "Run: npm install -g @anthropic-ai/claude-code"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Install-NodeJS
Install-Uv
Install-ClaudeCode
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  Claude Code CLI already installed, skipping`

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add Claude Code CLI installer"
```

---

### Task 12: Add OpenWhispr installer

**Files:**
- Modify: `install.ps1`

The installer always fetches the latest release from GitHub so it never goes stale. The Windows installer is the `OpenWhispr-Setup-*.exe` asset.

- [ ] **Step 1: Add Install-OpenWhispr function before the Main section**

```powershell
function Install-OpenWhispr {
    Write-Step "OpenWhispr (voice input)..."
    $appPath = "$env:LOCALAPPDATA\Programs\openwhispr\OpenWhispr.exe"
    if (Test-Path $appPath) { Write-Skipped "OpenWhispr"; return }
    try {
        $release = Invoke-RestMethod "https://api.github.com/repos/OpenWhispr/openwhispr/releases/latest"
        $asset   = $release.assets | Where-Object { $_.name -like "OpenWhispr-Setup-*.exe" } | Select-Object -First 1
        if (-not $asset) { throw "No Windows installer found in latest release" }
        $tmpFile = "$env:TEMP\OpenWhispr-Setup.exe"
        Invoke-WebRequest $asset.browser_download_url -OutFile $tmpFile
        Start-Process $tmpFile -ArgumentList "/S" -Wait
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        Write-Success "OpenWhispr"
    } catch {
        Write-Failed "OpenWhispr" "Download manually from https://openwhispr.com"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Install-NodeJS
Install-Uv
Install-ClaudeCode
Install-OpenWhispr
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `--  OpenWhispr already installed, skipping` (since you already have it installed).

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add OpenWhispr installer with dynamic latest-release detection"
```

---

### Task 13: Add VS Code extensions installer

**Files:**
- Modify: `install.ps1`

- [ ] **Step 1: Add Install-VSCodeExtensions function before the Main section**

```powershell
function Install-VSCodeExtensions {
    Write-Step "VS Code extensions (Python, GitLens)..."
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Failed "VS Code Extensions" "VS Code not in PATH -- restart PowerShell and re-run"
        return
    }
    try {
        code --install-extension ms-python.python --force | Out-Null
        code --install-extension eamodio.gitlens --force | Out-Null
        Write-Success "VS Code Extensions"
    } catch {
        Write-Failed "VS Code Extensions" "Run: code --install-extension ms-python.python then code --install-extension eamodio.gitlens"
    }
}
```

- [ ] **Step 2: Update the Main section**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Install-NodeJS
Install-Uv
Install-ClaudeCode
Install-OpenWhispr
Install-VSCodeExtensions
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `OK  VS Code Extensions installed` (extensions install silently, `--force` is idempotent).

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: add VS Code Python and GitLens extension installer"
```

---

### Task 14: Add AHK script deployment and startup registration

**Files:**
- Modify: `install.ps1`

The script downloads `MyShortCuts.ahk` from GitHub, places it in `Documents\AutoHotkey\`, registers it to run on Windows startup via the registry, and starts it immediately.

- [ ] **Step 1: Add Deploy-AHKScript function before the Main section**

```powershell
function Deploy-AHKScript {
    Write-Step "AutoHotkey script + startup registration..."
    $ahkDir  = "$env:USERPROFILE\Documents\AutoHotkey"
    $ahkDest = "$ahkDir\MyShortCuts.ahk"
    $ahkExe  = "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"

    if (-not (Test-Path $ahkDir)) {
        New-Item -ItemType Directory -Path $ahkDir -Force | Out-Null
    }

    try {
        Invoke-WebRequest "$GITHUB_RAW/assets/MyShortCuts.ahk" -OutFile $ahkDest
        $startupValue = "`"$ahkExe`" `"$ahkDest`""
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MyAHKShortcuts" -Value $startupValue
        if (Test-Path $ahkExe) {
            Start-Process $ahkExe -ArgumentList "`"$ahkDest`""
        }
        Write-Success "AHK Script + startup"
    } catch {
        Write-Failed "AHK Script" "Copy assets/MyShortCuts.ahk to $ahkDest manually"
    }
}
```

- [ ] **Step 2: Update the Main section to the final version**

```powershell
# ── Main ─────────────────────────────────────────────────────────────────────
Write-Banner
if (-not (Ensure-Winget)) { exit 1 }
Install-WindowsTerminal
Install-Git
Install-AutoHotkey
Install-VSCode
Install-NodeJS
Install-Uv
Install-ClaudeCode
Install-OpenWhispr
Install-VSCodeExtensions
Deploy-AHKScript
Show-Summary
```

- [ ] **Step 3: Run and verify**

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Expected: `OK  AHK Script + startup installed`. Verify the registry key exists:

```powershell
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object MyAHKShortcuts
```

Expected: Shows the path to AutoHotkey64.exe and MyShortCuts.ahk.

- [ ] **Step 4: Commit**

```bash
git add install.ps1
git commit -m "feat: deploy AHK script and register for Windows startup"
```

---

### Task 15: Push to GitHub and test the one-liner

**Files:**
- Modify: `install.ps1` (update username)
- Modify: `README.md` (update username)

- [ ] **Step 1: Create a public GitHub repo named ClaudeSoftwareBundle**

Go to github.com, create a new public repository named `ClaudeSoftwareBundle`. Do not initialize with README.

- [ ] **Step 2: Replace YOUR_GITHUB_USERNAME with your real username**

In `install.ps1`, update line 4:
```powershell
$GITHUB_RAW = "https://raw.githubusercontent.com/REAL_USERNAME/ClaudeSoftwareBundle/main"
```

In `README.md`, update the install command line with your real GitHub username.

- [ ] **Step 3: Push to GitHub**

```bash
git remote add origin https://github.com/REAL_USERNAME/ClaudeSoftwareBundle.git
git add install.ps1 README.md
git commit -m "fix: set real GitHub username in raw URLs"
git push -u origin main
```

- [ ] **Step 4: Full smoke test via one-liner**

Open a fresh PowerShell window (not the project directory) and run:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/REAL_USERNAME/ClaudeSoftwareBundle/main/install.ps1 | iex"
```

Expected: All tools show `--` (skipped, already installed). Summary prints cleanly. Next steps shown. No red errors.

- [ ] **Step 5: Commit is already done — verify on GitHub**

Visit `github.com/REAL_USERNAME/ClaudeSoftwareBundle` and confirm all files are visible: `install.ps1`, `assets/MyShortCuts.ahk`, `README.md`, `docs/`.
