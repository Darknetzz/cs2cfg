
$Path     = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive"
$FromPath = "csgo"
$ToPath   = "game"

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Output "Path $Path does not exist";
    exit 1;
}

# Build absolute source and destination paths
$SourceDir = Join-Path -Path $Path -ChildPath $FromPath
$DestDir   = Join-Path -Path $Path -ChildPath $ToPath

# Validate source exists
if (!(Test-Path -Path $SourceDir -PathType Container)) {
    Write-Error "Source directory '$SourceDir' does not exist."
    exit 1
}

# Ensure destination directory exists
if (!(Test-Path -Path $DestDir -PathType Container)) {
    Write-Error "Destination directory '$DestDir' does not exist."
    exit 1
}

try {
    # Copy the $FromPath directory into the $ToPath directory
    # This results in "$DestDir\$(Split-Path -Leaf $SourceDir)" being created/updated
    Copy-Item -Path $SourceDir -Destination $DestDir -Recurse -Force -Container -ErrorAction Stop
    Write-Output "Copied directory '$(Split-Path -Leaf $SourceDir)' into '$DestDir' successfully."
    Remove-Item -Path $SourceDir -Recurse
    Write-Output "Removed source directory '$(Split-Path -Leaf SourceDir)'"
    exit 0
} catch {
    Write-Error "Failed to copy directory: $($_.Exception.Message)"
    exit 1
}
