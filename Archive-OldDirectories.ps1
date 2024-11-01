<#
.SYNOPSIS
    Automatically compresses and archives old directories using 7-Zip.

.DESCRIPTION
    This script identifies directories that haven't been modified in the last 180 days,
    compresses them using 7-Zip, and removes the original directories after successful compression.
    It includes error handling and logging of all operations.

.PARAMETER DaysOld
    The minimum age in days for directories to be considered for archiving. Defaults to 180.

.PARAMETER 7zPath
    The path to the 7-Zip executable. Defaults to standard installation location.

.EXAMPLE
    .\Archive-OldDirectories.ps1
    Archives all directories older than 180 days in the current location.

.NOTES
    Requires 7-Zip to be installed on the system.
    Last Modified: 2024
#>

[CmdletBinding()]
param (
    [int]$DaysOld = 180,
    [string]$7zPath = "C:\Program Files\7-Zip\7z.exe"
)

# Import common functions
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
        [string]$7zPath
    )
    
    if (-not (Test-Path $7zPath)) {
        Write-LogMessage "7-Zip not found at: $7zPath" -Type "Error"
        Write-LogMessage "Please install 7-Zip or update the path in the script." -Type "Error"
        return $false
    }
    return $true
}

function Get-OldDirectories {
    param (
        [int]$DaysOld
    )
    
    $cutoffDate = (Get-Date).AddDays(-$DaysOld)
    $oldDirectories = Get-ChildItem -Directory | 
    Where-Object { $_.LastWriteTime -lt $cutoffDate }
    
    Write-LogMessage "Found $($oldDirectories.Count) directories older than $DaysOld days"
    
    if ($oldDirectories.Count -gt 0) {
        $oldDirectories | 
        Select-Object FullName, LastWriteTimeUtc | 
        Sort-Object LastWriteTimeUtc | 
        Format-Table
    }
    
    return $oldDirectories
}

function Compress-Directory {
    param (
        [string]$SourcePath,
        [string]$ArchivePath,
        [string]$7zPath
    )
    
    $arguments = @(
        "a"              # Add to archive
        "-t7z"          # Use 7z format
        "-mx=5"         # Compression level 5
        "-mmt=on"       # Enable multithreading
        "-r"            # Include subdirectories recursively
        "`"$ArchivePath`""
        "`"$SourcePath\*`""
    )
    
    $process = Start-Process -FilePath $7zPath -ArgumentList $arguments -NoNewWindow -Wait -PassThru
    return $process.ExitCode
}

function Remove-OriginalDirectory {
    param (
        [string]$DirectoryPath,
        [string]$ArchivePath
    )
    
    if (Test-Path $ArchivePath) {
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
        [string]$7zPath,
        [int]$DaysOld
    )
    
    if (-not (Test-7ZipInstallation -7zPath $7zPath)) {
        exit 1
    }
    
    $oldDirectories = Get-OldDirectories -DaysOld $DaysOld
    if ($oldDirectories.Count -eq 0) {
        Write-LogMessage "No directories found meeting the age criteria." -Type "Info"
        exit 0
    }
    
    foreach ($directory in $oldDirectories) {
        try {
            Write-LogMessage "Processing: $($directory.FullName)"
            $archivePath = "$($directory.FullName).7z"
            
            $exitCode = Compress-Directory -SourcePath $directory.FullName -ArchivePath $archivePath -7zPath $7zPath
            
            if ($exitCode -eq 0) {
                Write-LogMessage "Successfully compressed directory: $($directory.FullName)" -Type "Success"
                Remove-OriginalDirectory -DirectoryPath $directory.FullName -ArchivePath $archivePath
            }
            else {
                Write-LogMessage "7-Zip returned error code: $exitCode" -Type "Error"
            }
        }
        catch {
            Write-LogMessage "Failed to process directory: $($directory.FullName)" -Type "Error"
            Write-LogMessage "Error: $($_.Exception.Message)" -Type "Error"
        }
    }
}

try {
    Start-ArchivingProcess -7zPath $7zPath -DaysOld $DaysOld
}
catch {
    Write-LogMessage "Critical error occurred: $($_.Exception.Message)" -Type "Error"
    exit 1
}