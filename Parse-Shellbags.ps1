# Define the names of the files to search for
$filesToSearch = @("NTUSER.DAT", "UsrClass.dat")

# Loop through each directory recursively under the root directory
Get-ChildItem -Recurse -File -Include $filesToSearch | ForEach-Object {
    $filePath = $_.FullName
    Write-Host "Found file: $filePath"

    sbecmd -f $filePath --csv $($filePath)ShellBags
    
    Write-Host "sbecmd output for $filePath written to $outputPath"
}
