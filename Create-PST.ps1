# Create an Outlook COM Object
$outlook = New-Object -ComObject Outlook.Application

# The display name of the PST file you have manually added in Outlook
$pstDisplayName = "TA_Access"

# Directory containing the matched .msg files
$matchedDirectoryPath = "C:\Users\whearn\OneDrive - surefirecyber.com\Desktop\test\Matched"

# Try to get the PST file by its display name
$pstStore = $outlook.Session.Folders | Where-Object { $_.Name -eq $pstDisplayName } 

if ($null -eq $pstStore) {
    Write-Output "Error: Unable to find PST with display name: $pstDisplayName"
    exit
}

# Create a new folder in the PST file
$folder = $pstStore.Folders.Add("Imported Emails")

# Loop through each .msg file in the matched directory and add them to the new folder in the PST file
Get-ChildItem -Path $matchedDirectoryPath -Filter "*.msg" | ForEach-Object {
    try {
        $msgPath = $_.FullName
        $message = $outlook.CreateItemFromTemplate($msgPath)
        $message.Move($folder)
    } catch {
        Write-Output "Error importing $msgPath to PST: $_"
    }
}

# Release the Outlook COM Object
$outlook.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
