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
            "Installed" { Write-Host "  OK  $($item.Tool) installed" -ForegroundColor Green }
            "Skipped"   { Write-Host "  --  $($item.Tool) already installed, skipping" -ForegroundColor Gray }
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
    Add-Result "winget" "Failed" "Install 'App Installer' from the Microsoft Store, then re-run"
    return $false
}

function Install-WindowsTerminal {
    Write-Step "Windows Terminal..."
    # Windows Terminal is a Store app — Get-AppxPackage is more reliable than winget list
    $pkg = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
    if ($pkg) { Write-Skipped "Windows Terminal"; return }
    try {
        winget install --id Microsoft.WindowsTerminal --exact --silent --accept-package-agreements --accept-source-agreements
        Write-Success "Windows Terminal"
    } catch {
        Write-Failed "Windows Terminal" "Run: winget install Microsoft.WindowsTerminal"
    }
}

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

function Install-OpenWhispr {
    Write-Step "OpenWhispr (voice input)..."
    # OpenWhispr is an Electron app installed to LOCALAPPDATA
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
