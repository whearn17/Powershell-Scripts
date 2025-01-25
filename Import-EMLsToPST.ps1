param (
    [string]$EMLFolderPath,
    [string]$PSTPath
)

function Initialize-RDOSession {
    Write-Host "Starting email import process..."
    $rdoSession = New-Object -ComObject Redemption.RDOSession
    $rdoSession.Logon()
    Write-Host "Successfully logged into RDO session"
    return $rdoSession
}

function New-PSTStore {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PSTPath,
        [Parameter(Mandatory = $true)]
        $RDOSession
    )
    
    Write-Host "Creating new PST store at: $PSTPath"
    $pstStore = $RDOSession.Stores.AddPSTStore($PSTPath)
    return $pstStore
}

function Get-ImportFolder {
    param (
        [Parameter(Mandatory = $true)]
        $PSTStore,
        [string]$FolderName = "Imported Emails"
    )

    $topFolder = $PSTStore.RootFolder.Folders | Where-Object { $_.Name -eq "Top of Outlook data file" }
    $existingFolder = $topFolder.Folders | Where-Object { $_.Name -eq $FolderName }
    
    if (-not $existingFolder) {
        $topFolder.Folders.Add($FolderName)
        $existingFolder = $topFolder.Folders | Where-Object { $_.Name -eq $FolderName }
    }

    return $existingFolder, $topFolder
}

function Import-EMLToMSG {
    param (
        [Parameter(Mandatory = $true)]
        [string]$EMLPath,
        [Parameter(Mandatory = $true)]
        $RDOSession,
        [Parameter(Mandatory = $true)]
        $ImportFolder
    )

    $tempMsgPath = Join-Path $env:TEMP "temp_message.msg"
    Write-Host "Processing: $EMLPath"
    
    try {
        $rdoMail = $RDOSession.CreateMessageFromMsgFile($tempMsgPath)
        $rdoMail.Save()
        $rdoMail.Import($EMLPath, 1024)
        $rdoMail.Save()
        $rdoMail.CopyTo($ImportFolder)
        
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($rdoMail)
        Remove-Item $tempMsgPath -Force -ErrorAction SilentlyContinue
        
        Write-Host "Successfully imported: $EMLPath"
        return $true
    }
    catch {
        Write-Warning "Failed to import $EMLPath : $_"
        return $false
    }
}

function Cleanup-ComObjects {
    param (
        [Parameter(Mandatory = $true)]
        [array]$ComObjects
    )
    
    Write-Host "Starting cleanup of COM objects..."
    foreach ($obj in $ComObjects) {
        try {
            if ($obj) {
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($obj)
            }
        }
        catch {
            Write-Warning "Error releasing COM object: $_"
        }
    }
    
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Write-Host "Cleanup completed"
}

function Import-EMLsToPST {
    param (
        [Parameter(Mandatory = $true)]
        [string]$EMLFolderPath,
        [Parameter(Mandatory = $true)]
        [string]$PSTPath,
        [string]$ImportFolderName = "Imported Emails"
    )
    
    $ErrorActionPreference = "Stop"
    
    try {
        # Initialize session and create PST
        $rdoSession = Initialize-RDOSession
        $pstStore = New-PSTStore -PSTPath $PSTPath -RDOSession $rdoSession
        
        # Get or create import folder
        $importFolder, $topFolder = Get-ImportFolder -PSTStore $pstStore -FolderName $ImportFolderName
        
        # Process all EML files
        $emlFiles = Get-ChildItem -Path $EMLFolderPath -Filter "*.eml" -Recurse
        $totalFiles = $emlFiles.Count
        $successful = 0
        
        Write-Host "Found $totalFiles EML files to process"
        
        foreach ($emlFile in $emlFiles) {
            if (Import-EMLToMSG -EMLPath $emlFile.FullName -RDOSession $rdoSession -ImportFolder $importFolder) {
                $successful++
            }
        }
        
        Write-Host "Import complete. Successfully imported $successful of $totalFiles files"
    }
    catch {
        Write-Error "Fatal error during import process: $_"
    }
    finally {
        # Cleanup
        Cleanup-ComObjects -ComObjects @($importFolder, $topFolder, $pstStore, $rdoSession)
    }
}

function main() {
    Import-EMLsToPST -EMLFolderPath $EMLFolderPath -PSTPath $PSTPath
}

main