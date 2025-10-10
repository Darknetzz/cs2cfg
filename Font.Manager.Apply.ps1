
$Path     = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive"
$FromPath = "csgo"
$ToPath   = "game"

if (!Test-Path $Path) {
    Write-Output "Path $Path does not exist";
    exit 1;
}

if (!Test-Path $FromPath) {
    Write-Output "Source path $FromPath does not exist";
    exit 1;
}

if (!Test-Path $ToPath) {
    Write-Output "Destination path $ToPath does not exist";
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
    New-Item -Path $DestDir -ItemType Directory -Force | Out-Null
}

try {
    # Copy the $FromPath directory into the $ToPath directory
    # This results in "$DestDir\$(Split-Path -Leaf $SourceDir)" being created/updated
    Copy-Item -Path $SourceDir -Destination $DestDir -Recurse -Force -Container -ErrorAction Stop
    Write-Output "Copied directory '$(Split-Path -Leaf $SourceDir)' into '$DestDir' successfully."
    exit 0
}
catch {
    Write-Error "Failed to copy directory: $($_.Exception.Message)"
    exit 1
}
