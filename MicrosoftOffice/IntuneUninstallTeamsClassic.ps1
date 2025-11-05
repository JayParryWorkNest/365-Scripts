# Remediation script for Intune
# Uninstalls Classic Teams (per-user and machine-wide) silently

# Stop Teams process if running
Get-Process Teams -ErrorAction SilentlyContinue | Stop-Process -Force

# Uninstall per-user Teams
$perUserPath = "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe"
if (Test-Path $perUserPath) {
    & $perUserPath --uninstall -s
    Write-Output "Per-user Teams uninstalled."
}

# Uninstall machine-wide Teams
$machineWidePath = "C:\Program Files (x86)\Teams Installer\Teams.exe"
if (Test-Path $machineWidePath) {
    & $machineWidePath --uninstall -s
    Write-Output "Machine-wide Teams uninstalled."
}

# Optional cleanup of leftover folders
$paths = @(
    "$env:LOCALAPPDATA\Microsoft\Teams",
    "$env:PROGRAMFILES(X86)\Teams Installer",
    "$env:APPDATA\Microsoft\Teams"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
        Write-Output "Removed $path"
    }
}

Write-Output "Classic Teams removal completed."
exit 0
