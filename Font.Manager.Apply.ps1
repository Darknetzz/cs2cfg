#!/usr/bin/env pwsh
$Path     = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive"
$FromPath = "csgo"
$ToPath   = "game"

$exitCode = 0

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Output "Path $Path does not exist"
    $exitCode = 1
}

# Build absolute source and destination paths
$SourceDir = Join-Path -Path $Path -ChildPath $FromPath
$DestDir   = Join-Path -Path $Path -ChildPath $ToPath

if ($exitCode -eq 0) {
    # Validate source exists
    if (!(Test-Path -Path $SourceDir -PathType Container)) {
        Write-Error @"
Source directory '$SourceDir' does not exist.

This script merges the staging 'csgo' folder created by Font Manager CS2 into 'game'.
Run Font Manager CS2 first, click 'Apply Selected Font', then run this script again.
"@
        $exitCode = 1
    }

    # Ensure destination directory exists
    if ($exitCode -eq 0 -and !(Test-Path -Path $DestDir -PathType Container)) {
        Write-Error "Destination directory '$DestDir' does not exist."
        $exitCode = 1
    }
}

if ($exitCode -eq 0) {
    try {
        # Copy the $FromPath directory into the $ToPath directory
        # This results in "$DestDir\$(Split-Path -Leaf $SourceDir)" being created/updated
        Copy-Item -Path $SourceDir -Destination $DestDir -Recurse -Force -Container -ErrorAction Stop
        Write-Output "Copied directory '$(Split-Path -Leaf $SourceDir)' into '$DestDir' successfully."
        Remove-Item -Path $SourceDir -Recurse
        Write-Output "Removed source directory '$(Split-Path -Leaf $SourceDir)'"
    } catch {
        Write-Error "Failed to copy directory: $($_.Exception.Message)"
        $exitCode = 1
    }
}

Read-Host "Press Enter to exit"
exit $exitCode