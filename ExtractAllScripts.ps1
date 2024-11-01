#Usage:
#
#NOTE: The script expects an argument which is the full File Path of the EVTX file.  
#
#C:\>ExtractAllScripts.ps1  
#The default behavior of the script is to assimilate and extract every script/command to disk.
#
#C:\ExtractAllScripts -List
#This will only list Script Block IDs with associated Script Names(if logged.)
#
#C:\>ExtractAllScripts.ps1 -ScriptBlockID aeb8cd23-3052-44f8-b6ba-ff3c083e912d
#This will only extract the script corresponding to the user specified ScriptBlock ID
#
#Twitter: @vikas891

$ErrorActionPreference = 'silentlycontinue'
$Question = read-host "Please provide full path of PowerShell Operational EVTX:"
param ($ScriptBlockID, [switch]$List)
$StoreArrayHere = Get-WinEvent -FilterHashtable @{ Path = "$Question"; ProviderName = "Microsoft-Windows-PowerShell"; Id = 4104 } 
$Desc = $StoreArrayHere | sort -Descending { $_.Properties[1].Value } 
$ArrayofUniqueIDs = @()
    
if (!$ScriptBlockID) {
    $Desc | % { $ArrayofUniqueIDs += $_.Properties[3].Value }
}
else {
    $Desc | % { $ArrayofUniqueIDs += $_.Properties[3].Value }
    if ($ScriptBlockID -in $ArrayofUniqueIDs) {
        $ArrayofUniqueIDs = $ScriptBlockID
    }
    else {
        ""
        Write-Host "[!] Specified Script Block ID does not exist. Exiting.." -ForegroundColor Red
        break
    }
}
$ArrayofUniqueIDs = $ArrayofUniqueIDs | select -Unique

if ($List) {
    foreach ($a in $ArrayofUniqueIDs) {
        $Temp = $StoreArrayHere | Where-Object { $_.Message -like "*$a*" }
        $SortIt = $Temp | sort { $_.Properties[0].Value } 
        ""
        if ($SortIt[0].Properties[4].Value) {
            $OriginalName = Split-Path -Path $SortIt[0].Properties[4].Value -Leaf
            $FileName = "$($a)_$($OriginalName)"
            $DisplayName = $SortIt[0].Properties[4].Value
        }
        else {
            $OriginalName = ''
            $FileName = $a
            $DisplayName = 'NULL'
        }
        Write-Host -NoNewline "Script ID: " 
        Write-Host -NoNewline $a -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor White
        Write-Host -NoNewline "Script Name:"
        Write-Host -NoNewline $DisplayName -ForegroundColor Magenta
        $NumberOfRecords = $Temp.Count
        $MessageTotal = $Temp[0] | % { $_.Properties[1].Value }
        if ($NumberOfRecords -eq $MessageTotal) {
            Write-Host -NoNewline " | Complete Script " -ForegroundColor Green
            Write-Host -NoNewline " | Event Records Logged"$NumberOfRecords/$MessageTotal
            ""
        }
        else {
            Write-Host -NoNewline " | InComplete Script Logged" -ForegroundColor Red
            Write-Host -NoNewline " | Event Records Logged"$NumberOfRecords/$MessageTotal
            ""
        }    
    }
    break
}
    
foreach ($a in $ArrayofUniqueIDs) {
    $Temp = $StoreArrayHere | Where-Object { $_.Message -like "*$a*" }
    $SortIt = $Temp | sort { $_.Properties[0].Value } 
    ""
    if ($SortIt[0].Properties[4].Value) {
        $OriginalName = Split-Path -Path $SortIt[0].Properties[4].Value -Leaf
        $FileName = "$($a)_$($OriginalName)"
        $DisplayName = $SortIt[0].Properties[4].Value
    }
    else {
        $OriginalName = ''
        $FileName = $a
        $DisplayName = 'NULL'
    }
    Write-Host -NoNewline "Extracting " 
    Write-Host -NoNewline $a -ForegroundColor Yellow
    if ($OriginalName) {
        Write-Host -NoNewline _$OriginalName -ForegroundColor Magenta
    }
    Write-Host -NoNewline " | " -ForegroundColor White
    Write-Host -NoNewline "ScriptName:"
    Write-Host -NoNewline $DisplayName -ForegroundColor Magenta
    $MergedScript = -join ($SortIt | % { $_.Properties[2].Value }) | Out-File $FileName
    $NumberOfRecords = $Temp.Count
    $MessageTotal = $Temp[0] | % { $_.Properties[1].Value }
    if ($NumberOfRecords -eq $MessageTotal) {
        Write-Host -NoNewline " | Complete Script Logged  " -ForegroundColor Green
        Write-Host -NoNewline " | Event Records Exported"$NumberOfRecords/$MessageTotal
        Write-Host -NoNewline " | Number of lines" (Get-Content $FileName).Length
        ""
    }
    else {
        Write-Host -NoNewline " | InComplete Script Logged" -ForegroundColor Red
        ren $FileName "$FileName.partial"
        Write-Host -NoNewline " | Event Records Exported"$NumberOfRecords/$MessageTotal
        Write-Host -NoNewline " | Number of lines" (Get-Content "$FileName.partial").Length
        ""
    }
    $FileName = ''    
}