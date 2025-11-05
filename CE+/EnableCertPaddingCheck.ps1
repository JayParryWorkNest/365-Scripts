$registryPaths = @(
    "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config",
    "HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config"
)

foreach ($path in $registryPaths) {
    if (-not (Test-Path $path)) {
        try {
            New-Item -Path $path -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-Warning "Failed to create registry path"
            continue
        }
    }

    try {
        Set-ItemProperty -Path $path -Name "EnableCertPaddingCheck" -Value 1 -Type DWord -ErrorAction Stop
    } catch {
        Write-Warning "Failed to create DWORD"
    }
}