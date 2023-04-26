# This script searches through the root of an specified directory and all subdirectories, gathering all files in each directory, and displaying
# the name of the file, the last time it was written to, the last time it was accessed, and the owner, then exports the information to a csv

$rootFolder = "redacted"
$outputCSV = "redacted"


Get-ChildItem -Path $rootFolder -Recurse -File | ForEach-Object {
    $file = $_
    $owner = (Get-Acl -LiteralPath $file.FullName).Owner
    [PSCustomObject]@{
        Name = $file.Name
        LastWriteTime = $file.LastWriteTime
        LastAccessTime = $file.LastAccessTime
        Owner = $owner
    }
} | Export-Csv -Path $outputCSV -NoTypeInformation
