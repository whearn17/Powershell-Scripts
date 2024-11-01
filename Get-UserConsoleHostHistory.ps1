$filename = "ConsoleHost_history.txt"

try {
    $foundFiles = Get-ChildItem -Recurse -File -Filter $filename -ErrorAction SilentlyContinue
    
    if ($foundFiles) {
        foreach ($file in $foundFiles) {
            $fullPath = $file.FullName

            if ($fullPath -match '\\Users\\([^\\]+)') {
                $username = $matches[1]
            }
            else {
                $username = "Username not found"
            }

            if ($fullPath -match '\\Collection-([^\\]+)') {
                $machineName = $matches[1]
            }
            else {
                $machineName = "Machine name not found"
            }

            Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
            Write-Host "File: $fullPath" -ForegroundColor Green
            Write-Host "Username: $username" -ForegroundColor Yellow
            Write-Host "Machine Name: $machineName" -ForegroundColor Magenta

            Write-Host "`nFile Content:" -ForegroundColor Cyan
            Get-Content -Path $fullPath | ForEach-Object { Write-Host $_ -ForegroundColor White }

            Write-Host "`n══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "No file named $filename found." -ForegroundColor Red
    }
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    exit 1
}
