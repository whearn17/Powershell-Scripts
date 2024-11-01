# Define the path to the directory containing the .lnk files
$directoryPath = ".\"

# Define the path to the output file
$outputFile = ".\parsed.csv"

# Create a Shell Application object
$shell = New-Object -ComObject WScript.Shell

# Get all .lnk files in the directory
$lnkFiles = Get-ChildItem -Path $directoryPath -Filter *.lnk

$results = foreach ($lnkFile in $lnkFiles) {
    $shortcut = $shell.CreateShortcut($lnkFile.FullName)
    [PSCustomObject]@{
        'FileName'   = $lnkFile.Name
        'TargetPath' = $shortcut.TargetPath
        'Arguments'  = $shortcut.Arguments
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputFile -NoTypeInformation
