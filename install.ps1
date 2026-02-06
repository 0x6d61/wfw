#Requires -Version 5.1
<#
.SYNOPSIS
    Install wfw module to current user's module directory

.DESCRIPTION
    Copies the wfw module to $HOME\Documents\WindowsPowerShell\Modules\wfw (or similar based on environment).
    This allows 'wfw' command to be used from any PowerShell session.
#>

$ErrorActionPreference = "Stop"

$moduleName = "wfw"
$srcDir = Join-Path $PSScriptRoot "src" $moduleName

# Detect user module path (usually the first one in PSModulePath that is in user's home)
$userModulePath = $env:PSModulePath.Split(';') | Where-Object { $_ -like "*$env:USERNAME*" -and (Test-Path $_) } | Select-Object -First 1

if (-not $userModulePath) {
    # Fallback to standard Documents path if detection fails or path doesn't exist yet
    $docs = [Environment]::GetFolderPath("MyDocuments")
    $userModulePath = Join-Path $docs "WindowsPowerShell\Modules"
}

if (-not (Test-Path $userModulePath)) {
    Write-Host "Creating module directory: $userModulePath"
    New-Item -Path $userModulePath -ItemType Directory -Force | Out-Null
}

$destDir = Join-Path $userModulePath $moduleName

Write-Host "Installing wfw to: $destDir"

if (Test-Path $destDir) {
    Write-Host "Removing existing installation..." -ForegroundColor Yellow
    Remove-Item -Path $destDir -Recurse -Force
}

Write-Host "Copying module files..."
Copy-Item -Path $srcDir -Destination $userModulePath -Recurse -Force

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Please restart your PowerShell session or run:"
Write-Host "    Import-Module wfw" -ForegroundColor Cyan
Write-Host "Then you can use 'wfw' command anywhere."
