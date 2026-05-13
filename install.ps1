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
