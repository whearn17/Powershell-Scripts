Get-ChildItem * -Recurse -Include SYSTEM | ForEach-Object {
    $FNAME = $_.DirectoryName.split("Collection-")[1].split("\")[0]
    Write-Output $FNAME
    RECmd.exe -f $_.FullName --regex --sd "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" --nl --details | Select-String "IPAddress" > $FNAME-IP.txt
}