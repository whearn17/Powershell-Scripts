# This script splits a CSV file into multiple files with the same headers

param (
    [string]$inputFile = "input.csv",
    [Int16]$splitInto = 2 
)

function Write-Usage {
    Write-Host "Usage: SplitCsv.ps1 -inputFile <input.csv> -splitInto <2>"
}

if ($inputFile -eq "" -or $splitInto -eq 0) {
    Write-Usage
    exit
}

$csv = Import-Csv $inputFile

$splitSize = [math]::Ceiling($csv.Count / $splitInto)

for ($i = 0; $i -lt $splitInto; $i++) {
    $start = $i * $splitSize
    $end = ($i + 1) * $splitSize
    if ($end -gt $csv.Count) {
        $end = $csv.Count
    }
    $csv[$start..($end - 1)] | Export-Csv -NoTypeInformation -Path ("output" + $i + ".csv")
}

Write-Host "Split into $splitInto files"
