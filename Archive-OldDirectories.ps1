<#
.SYNOPSIS
    Automatically compresses and archives old directories using 7-Zip.

.DESCRIPTION
    This script identifies directories that haven't been modified in the last specified number of days,
    compresses them using 7-Zip, and removes the original directories after successful compression.
    It only processes directories in the current working directory.

.PARAMETER DaysOld
    The minimum age in days for directories to be considered for archiving. Defaults to 180.

.PARAMETER SevenZipPath
    The path to the 7-Zip executable. Defaults to standard installation location.

.EXAMPLE
    .\Archive-OldDirectories.ps1
    Archives all directories older than 180 days in the current location.

.EXAMPLE
    .\Archive-OldDirectories.ps1 -DaysOld 92
    Archives all directories older than 92 days in the current location.

.NOTES
    Requires 7-Zip to be installed on the system.
    Last Modified: 2024
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [int]$DaysOld = 180,
    
    [Parameter(Position = 1)]
    [string]$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
)

function Write-LogMessage {
    param (
        [string]$Message,
        [string]$Type = "Info"  # Info, Success, Warning, Error
    )
    
    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "White" }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor $color
}

function Test-7ZipInstallation {
    param (
        [string]$SevenZipPath
    )
    
    if (-not (Test-Path $SevenZipPath)) {
        Write-LogMessage "7-Zip not found at: $SevenZipPath" -Type "Error"
        Write-LogMessage "Please install 7-Zip or update the path in the script." -Type "Error"
        return $false
    }
    return $true
}

function Get-OldDirectories {
    param (
        [int]$DaysOld
    )
    
    $currentLocation = Get-Location
    Write-LogMessage "Scanning directory: $currentLocation" -Type "Info"
    
    $cutoffDate = (Get-Date).AddDays(-$DaysOld)
    $oldDirectories = Get-ChildItem -Path $currentLocation -Directory | 
    Where-Object { $_.LastWriteTime -lt $cutoffDate }
    
    Write-LogMessage "Found $($oldDirectories.Count) directories older than $DaysOld days"
    
    return $oldDirectories
}

function Compress-Directory {
    param (
        [string]$SourcePath,
        [string]$ArchivePath,
        [string]$SevenZipPath
    )
    
    Write-LogMessage "Creating archive: $ArchivePath" -Type "Info"
    
    $arguments = @(
        "a"             # Add to archive
        "-t7z"          # Use 7z format
        "-mx=5"         # Compression level 5
        "-mmt=on"       # Enable multithreading
        "-r"            # Include subdirectories recursively
        "`"$ArchivePath`""
        "`"$SourcePath\*`""
    )
    
    $process = Start-Process -FilePath $SevenZipPath -ArgumentList $arguments -NoNewWindow -Wait -PassThru
    return $process.ExitCode
}

function Remove-OriginalDirectory {
    param (
        [string]$DirectoryPath,
        [string]$ArchivePath
    )
    
    if (Test-Path $ArchivePath) {
        $archiveInfo = Get-Item $ArchivePath
        $directoryInfo = Get-Item $DirectoryPath
        if ($archiveInfo.Length -eq 0) {
            Write-LogMessage "Archive file is empty - skipping directory removal: $ArchivePath" -Type "Error"
            return $false
        }
        
        Remove-Item -Path $DirectoryPath -Recurse -Force
        Write-LogMessage "Removed original directory: $DirectoryPath" -Type "Success"
        return $true
    }
    else {
        Write-LogMessage "Archive file not found - skipping directory removal: $ArchivePath" -Type "Warning"
        return $false
    }
}

function Start-ArchivingProcess {
    param (
        [string]$SevenZipPath,
        [int]$DaysOld
    )
    
    if (-not (Test-7ZipInstallation -SevenZipPath $SevenZipPath)) {
        exit 1
    }
    
    $oldDirectories = Get-OldDirectories -DaysOld $DaysOld
    if ($oldDirectories.Count -eq 0) {
        Write-LogMessage "No directories found meeting the age criteria." -Type "Info"
        exit 0
    }
    
    foreach ($directory in $oldDirectories) {
        try {
            Write-LogMessage "Processing: $($directory.Name)"
            
            $directoryPath = $directory.FullName
            $archivePath = Join-Path -Path (Get-Location) -ChildPath "$($directory.Name).7z"
            
            $exitCode = Compress-Directory -SourcePath $directoryPath -ArchivePath $archivePath -SevenZipPath $SevenZipPath
            
            if ($exitCode -eq 0) {
                Write-LogMessage "Successfully compressed directory: $($directory.Name)" -Type "Success"
                Remove-OriginalDirectory -DirectoryPath $directoryPath -ArchivePath $archivePath
            }
            else {
                Write-LogMessage "7-Zip returned error code: $exitCode" -Type "Error"
            }
        }
        catch {
            Write-LogMessage "Failed to process directory: $($directory.Name)" -Type "Error"
            Write-LogMessage "Error: $($_.Exception.Message)" -Type "Error"
        }
    }
}

try {
    Start-ArchivingProcess -SevenZipPath $SevenZipPath -DaysOld $DaysOld
}
catch {
    Write-LogMessage "Critical error occurred: $($_.Exception.Message)" -Type "Error"
    exit 1
}