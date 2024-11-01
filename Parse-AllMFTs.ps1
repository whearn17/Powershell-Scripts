function Process-UsnJrnl {
    Get-ChildItem -Path $path -Recurse -Include '$UsnJrnl%3A$J' | ForEach-Object -Parallel {
        $startIndex = $_.FullName.IndexOf('Collection-')
        $endIndex = $_.FullName.IndexOf('\', $startIndex)
        $collectionName = $_.FullName.Substring($startIndex, $endIndex - $startIndex)

        $parentDir = Split-Path $_.Directory -Parent
        $mftFile = Join-Path $parentDir '$MFT'
    
        MFTECmd.exe -f $_.FullName -m $mftFile --csv "USNJRNL_ALL_COLLECTIONS" --csvf "$collectionName`$J.csv"
    } -ThrottleLimit 5
}

function Process-MFT {
    Get-ChildItem -Path $path -Recurse -Include `$MFT | ForEach-Object -Parallel {
        $startIndex = $_.FullName.IndexOf('Collection-')
        $endIndex = $_.FullName.IndexOf('\', $startIndex)
        $collectionName = $_.FullName.Substring($startIndex, $endIndex - $startIndex)

        MFTECmd.exe -f $_.FullName --at --csv "MFT_ALL_COLLECTIONS" --csvf "$collectionName`$MFT.csv"
    } -ThrottleLimit 5
}


Process-UsnJrnl

Process-MFT