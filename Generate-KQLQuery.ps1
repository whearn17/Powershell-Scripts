# Begin script
$subjectsFilePath = "D:\Cases\S23BCS05EGI-Egide Group\subjects.txt"

# Check if the file exists
if (-Not (Test-Path -Path $subjectsFilePath -PathType Leaf)) {
    Write-Host "File does not exist: $subjectsFilePath"
    return
}

# Read the content of the file
$subjects = Get-Content $subjectsFilePath

# Initialize an empty array to hold the cleaned up subjects
$cleanedSubjects = @()

foreach ($subject in $subjects) {
    # Trim spaces at the end of the line and ignore empty lines
    $cleanSubject = $subject.TrimEnd()
    if ($cleanSubject.Length -gt 0) {
        # Replace all non-ASCII characters with space
        $cleanSubject = $cleanSubject -replace '[^\x00-\x7F]', ' '
        # Replace all special characters with nothing
        $cleanSubject = $cleanSubject -replace '[^\w\d\s]', ''
        $cleanSubject = $cleanSubject -replace '[“”]', ''
        $cleanedSubjects += '"' + $cleanSubject + '"'
    }
}

# Create the KQL query
$query = "subject CONTAINS " + ($cleanedSubjects -join " OR ")

# Copy the query to clipboard
$query | Set-Clipboard

# Also output the query to console
$query
# End script
