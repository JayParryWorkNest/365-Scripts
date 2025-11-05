# Run as SYSTEM or an admin on the device
$results = @()

# check machine-wide Teams installer
$machineTeamsPath = "$env:ProgramFiles\Teams Installer\TeamsMachineInstaller.exe"
if (Test-Path $machineTeamsPath) {
  $v = (Get-Item $machineTeamsPath).VersionInfo.ProductVersion
  $results += [pscustomobject]@{Path=$machineTeamsPath; Version=$v; Context="MachineInstaller"}
}

# check current user / all user profiles for user-installed Teams.exe
$profiles = Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -and $_.Loaded -eq $false -or $true } 
# iterate profile folders
foreach ($p in $profiles) {
  $localTeams = Join-Path $p.LocalPath "AppData\Local\Microsoft\Teams\current\Teams.exe"
  if (Test-Path $localTeams) {
    $v = (Get-Item $localTeams).VersionInfo.ProductVersion
    $results += [pscustomobject]@{Path=$localTeams; Version=$v; Profile=$p.LocalPath; Context="PerUser"}
  }
}

# also check Program Files x86 for old installs
$possible = Get-ChildItem "C:\Program Files*", "C:\Program Files (x86)*" -Recurse -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -ieq "Teams.exe" } |
           ForEach-Object { [pscustomobject]@{Path=$_.FullName; Version=$_.VersionInfo.ProductVersion } }

$results += $possible
$results | Sort-Object Version -Unique
$results | Format-Table -AutoSize
