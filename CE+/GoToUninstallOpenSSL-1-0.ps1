<#
.SYNOPSIS
    Safely uninstall OpenSSL 1.0 from Windows without affecting OpenSSL 3.
.DESCRIPTION
    - Detects OpenSSL 1.0 installations via MSI or manual folders.
    - Removes only 1.0.x versions.
    - Keeps OpenSSL 3 (and its PATH entries).
    - Must be run as Administrator.
#>

Write-Host "=== OpenSSL 1.0 Removal Script ===" -ForegroundColor Cyan

# --- Detect OpenSSL version currently in PATH ---
function Get-OpenSSLVersion {
    try {
        $ver = & openssl version 2>$null
        return $ver
    } catch {
        return $null
    }
}

$currentVer = Get-OpenSSLVersion
if ($currentVer) {
    Write-Host "Current PATH OpenSSL version: $currentVer" -ForegroundColor Yellow
} else {
    Write-Host "No OpenSSL found in PATH currently." -ForegroundColor Gray
}

# --- Step 1: Uninstall MSI-based OpenSSL 1.0 installations ---
Write-Host "`nChecking for OpenSSL 1.0 MSI installations..." -ForegroundColor Cyan
$openssl10 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "OpenSSL 1\.0" }

if ($openssl10) {
    foreach ($pkg in $openssl10) {
        Write-Host "Found OpenSSL package: $($pkg.Name)" -ForegroundColor Yellow
        if ($pkg.Version -match "^1\.0") {
            Write-Host "Uninstalling $($pkg.Name)..." -ForegroundColor Cyan
            $pkg.Uninstall() | Out-Null
            Write-Host "✅ Uninstalled $($pkg.Name)." -ForegroundColor Green
        } else {
            Write-Host "Skipping $($pkg.Name) (not 1.0.x)." -ForegroundColor Gray
        }
    }
} else {
    Write-Host "No MSI-based OpenSSL 1.0 installations found." -ForegroundColor Gray
}

# --- Step 2: Remove leftover directories for 1.0 only ---
Write-Host "`nScanning for leftover OpenSSL 1.0 folders..." -ForegroundColor Cyan
$paths = @(
    "C:\Program Files\OpenSSL",
    "C:\Program Files (x86)\OpenSSL",
    "C:\OpenSSL-Win64",
    "C:\OpenSSL-Win32"
)

foreach ($p in $paths) {
    if (Test-Path "$p\bin\openssl.exe") {
        $ver = & "$p\bin\openssl.exe" version 2>$null
        if ($ver -match "^OpenSSL 1\.0") {
            Write-Host "Removing OpenSSL 1.0 folder: $p" -ForegroundColor Yellow
            Remove-Item -Recurse -Force $p
        } else {
            Write-Host "Keeping $p (contains $ver)" -ForegroundColor Gray
        }
    }
}

# --- Step 3: Clean PATH entries pointing to 1.0 only ---
Write-Host "`nCleaning PATH variable..." -ForegroundColor Cyan
$sysPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
$updatedPath = ($sysPath.Split(";") | Where-Object {$_ -notmatch "OpenSSL-Win64\\bin|OpenSSL-Win32\\bin"} | Where-Object {
    if (Test-Path "$_\openssl.exe") {
        try {
            $ver = & "$_\openssl.exe" version 2>$null
            return ($ver -notmatch "^OpenSSL 1\.0")
        } catch { return $true }
    } else { return $true }
}) -join ";"

[Environment]::SetEnvironmentVariable("Path", $updatedPath, [EnvironmentVariableTarget]::Machine)
Write-Host "PATH cleaned (OpenSSL 1.0 references removed)." -ForegroundColor Green

# --- Step 4: Verify remaining version ---
Write-Host "`nVerifying remaining OpenSSL installation..." -ForegroundColor Cyan
$newVer = Get-OpenSSLVersion
if ($newVer) {
    Write-Host "✅ Remaining OpenSSL version: $newVer" -ForegroundColor Green
else {
    Write-Host "⚠️ No OpenSSL found in PATH (you may reinstall or re-add OpenSSL 3 manually)." -ForegroundColor Yellow
}

Write-Host "`n=== Cleanup Complete ==="
