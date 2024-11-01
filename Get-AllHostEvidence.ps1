# This script will run various forensic tools to output informatiom that will allow me to make sure the host has not been compromised.

param (
    [Parameter(Mandatory = $true)]
    [string]$HostDirectory
)

$hostName = $HostDirectory.Split("-")[1]

$output = New-Item -ItemType Directory -Path ".\$($hostName)"

$mftPath = (Get-ChildItem -Path $HostDirectory -Recurse -File -Include "`$MFT").FullName
$amcachePath = (Get-ChildItem -Path $HostDirectory -Recurse -File -Include "Amcache.hve").FullName
$prefetchPath = (Get-ChildItem -Path $HostDirectory -Recurse -Directory -Include "Prefetch").FullName
$softwareHivePath = (Get-ChildItem -Path $HostDirectory -Recurse -File -Include "SOFTWARE").FullName
$localSessionManagerLogPath = (Get-ChildItem -Path $HostDirectory -Recurse -File -Include "LocalSessionManager.evtx").FullName

function Get-MFT {
    MFTECmd.exe -f $mftPath --csv ".\$($output)\"
}

function Get-ProgramExecution {
    AmcacheParser.exe -f $amcachePath --csv ".\$($output)\"
    PECmd.exe -f $prefetchPath --csv ".\$($output)\"
}

function Get

function main() {
    Get-MFT
    Get-ProgramExecution
}

main()
