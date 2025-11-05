<#
.SYNOPSIS
    Intune Remediation Script for OpenSSL 1.0
.DESCRIPTION
    Safely removes OpenSSL 1.0 without affecting OpenSSL 3
    Should be run as SYSTEM
#>

Write-Host "=== OpenSSL 1.0 Remediation ==="

# --- Step 1: Remove MSI installations of OpenSSL 1.0 ---
$opensslMSI = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "OpenSSL 1\.0" }
foreach ($pkg in $opensslMSI) {
    if ($pkg.Version -match "^1\.0") {
        Write-Host "Uninstalling MSI package: $($pkg.Name)"
        $pkg.Uninstall() | Out-Null
    }
}

# --- Step 2: Remove leftover folders (OpenSSL 1.0 only) ---
$folders = @(
    "C:\Program Files\OpenSSL",
    "C:\Program Files (x86)\OpenSSL",
    "C:\OpenSSL-Win64",
    "C:\OpenSSL-Win32"
)
foreach ($p in $folders) {
    if (Test-Path "$p\bin\openssl.exe") {
        $ver = & "$p\bin\openssl.exe" version 2>$null
        if ($ver -match "^OpenSSL 1\.0") {
            Write-Host "Removing OpenSSL 1.0 folder: $p"
            Remove-Item -Recurse -Force $p
        }
    }
}

# --- Step 3: Clean PATH environment variable ---
$sysPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
$updatedPath = ($sysPath.Split(";") | Where-Object {
    if (Test-Path "$_\openssl.exe") {
        try {
            $ver = & "$_\openssl.exe" version 2>$null
            return ($ver -notmatch "^OpenSSL 1\.0")
        } catch { return $true }
    } else { return $true }
}) -join ";"
[Environment]::SetEnvironmentVariable("Path", $updatedPath, [EnvironmentVariableTarget]::Machine)

Write-Host "PATH cleaned of OpenSSL 1.0 entries."

# --- Step 4: Verify removal ---
try {
    $remaining = & openssl version 2>$null
    if ($remaining -match "^OpenSSL 1\.0") {
        Write-Host "❌ OpenSSL 1.0 still detected: $remaining"
        exit 1
    } else {
        Write-Host "✅ OpenSSL 1.0 removed. Remaining version: $remaining"
        exit 0
    }
} catch {
    Write-Host "✅ OpenSSL 1.0 successfully removed. No OpenSSL in PATH."
    exit 0
}
