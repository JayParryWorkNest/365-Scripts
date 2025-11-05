<#
.SYNOPSIS
    Intune Detection Script for OpenSSL 1.0
.DESCRIPTION
    Returns exit code 1 if OpenSSL 1.0 is found (non-compliant)
    Returns exit code 0 if OpenSSL 1.0 is not found (compliant)
#>

# Function to get OpenSSL version
function Get-OpenSSLVersion {
    try {
        $ver = & openssl version 2>$null
        return $ver
    } catch {
        return $null
    }
}

# Check PATH OpenSSL
$currentVer = Get-OpenSSLVersion
if ($currentVer -and $currentVer -match "^OpenSSL 1\.0") {
    Write-Host "OpenSSL 1.0 detected in PATH: $currentVer"
    exit 1  # Non-compliant
}

# Check MSI-installed OpenSSL 1.0
$opensslMSI = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "OpenSSL 1\.0" }
if ($opensslMSI) {
    Write-Host "OpenSSL 1.0 MSI installation detected."
    exit 1  # Non-compliant
}

# Check common manual folders
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
            Write-Host "OpenSSL 1.0 folder detected: $p"
            exit 1  # Non-compliant
        }
    }
}

Write-Host "No OpenSSL 1.0 detected."
exit 0  # Compliant
