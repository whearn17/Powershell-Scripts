# This script reads in a CSV file containing Microsoft audit logs with nested JSON data and extracts the nested JSON data into a new CSV file.
# The CSV file will have multiple columns that do not contain nested JSON data, and one column that contains nested JSON data.

param (
    [Parameter(Mandatory=$true)]
    [string]$File
)

function Convert-ColumnFromJSONToMoreColumns {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Column
    )

    $Column | ConvertFrom-Json
}

function main {
    $indexOfJsonColumn = 4
    $data = Import-Csv -Path $File
    $outputData = @()
    foreach ($row in $data) {
        $newColumns = Convert-ColumnFromJSONToMoreColumns -Column $indexOfJsonColumn
        $outputData += $newColumns
        $row.PSObject.Properties.Remove($indexOfJsonColumn)
    }

    $outputData | Export-Csv -Path "$($File.Split('\')[-1])_unpacked.csv" -NoTypeInformation
}

main