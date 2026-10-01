#!/usr/bin/env pwsh
$exitCode = 0

function Get-FontManagerCsgoPath {
    $settingsFile = Join-Path $env:APPDATA 'Font Manager\Data\settings.json'
    if (-not (Test-Path -LiteralPath $settingsFile)) {
        return $null
    }

    try {
        $csgoPath = (Get-Content -LiteralPath $settingsFile -Raw | ConvertFrom-Json).CsgoPath
        if ($csgoPath) {
            return $csgoPath
        }
    } catch {
        Write-Warning "Could not read Font Manager settings: $($_.Exception.Message)"
    }

    return $null
}

function Get-FontManagerStagingDir {
    param([string]$Root)

    $candidates = @(
        (Join-Path $Root 'csgo')
    )

    foreach ($candidate in $candidates | Select-Object -Unique) {
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

$InstallRoot = Get-FontManagerCsgoPath
if (-not $InstallRoot) {
    Write-Error "Could not read CsgoPath from Font Manager settings ($env:APPDATA\Font Manager\Data\settings.json)."
    $exitCode = 1
}

if ($exitCode -eq 0) {
    $DestDir     = Join-Path $InstallRoot 'game'
    $GameCsgoDir = Join-Path $DestDir 'csgo'
}

if ($exitCode -eq 0 -and -not (Test-Path -LiteralPath $InstallRoot -PathType Container)) {
    Write-Error "Install root '$InstallRoot' does not exist."
    $exitCode = 1
}

if ($exitCode -eq 0 -and -not (Test-Path -LiteralPath $DestDir -PathType Container)) {
    Write-Error "Destination directory '$DestDir' does not exist."
    $exitCode = 1
}

if ($exitCode -eq 0) {
    $SourceDir = Get-FontManagerStagingDir -Root $InstallRoot

    if ($null -eq $SourceDir) {
        $gameFontsDir = Join-Path $GameCsgoDir 'panorama\fonts'
        if (Test-Path -LiteralPath $gameFontsDir -PathType Container) {
            Write-Output @"
No staging 'csgo' folder found to merge.

Fonts already appear to be in '$gameFontsDir'.
If the font is already working in-game, you are done.

To change fonts again:
  1. Open Font Manager CS2 and click 'Apply Selected Font'
  2. Confirm a new 'csgo' folder appears next to 'game' in:
     $InstallRoot
  3. Run this script again to merge it into 'game'
"@
        } else {
            Write-Error @"
No staging 'csgo' folder found at '$InstallRoot\csgo'.

Run Font Manager CS2 first, click 'Apply Selected Font', then run this script again.
If Font Manager says it applied but no folder appears, run it as Administrator.
"@
            $exitCode = 1
        }
    } elseif ($SourceDir -eq (Resolve-Path -LiteralPath $GameCsgoDir).Path) {
        Write-Output "Font Manager output is already in '$GameCsgoDir'. Nothing to merge."
    } else {
        try {
            Copy-Item -LiteralPath $SourceDir -Destination $DestDir -Recurse -Force -Container -ErrorAction Stop
            Write-Output "Copied directory '$(Split-Path -Leaf $SourceDir)' into '$DestDir' successfully."
            Remove-Item -LiteralPath $SourceDir -Recurse -Force
            Write-Output "Removed staging directory '$(Split-Path -Leaf $SourceDir)'."
        } catch {
            Write-Error "Failed to copy directory: $($_.Exception.Message)"
            $exitCode = 1
        }
    }
}

Read-Host "Press Enter to exit"
exit $exitCode
