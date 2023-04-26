Import-Module ActiveDirectory

Get-ADComputer -Filter * | 
ForEach-Object { 
    $computer = $_.Name 

    try {
        $ip = [System.Net.Dns]::GetHostAddresses($computer) | 
                Select-Object -First 1 
        if ($ip -ne $null) {
            Write-Output "${computer}: ${ip}" 
        } else {
            Write-Output "${computer}: IP address not set or cannot be retrieved"
        }
    } catch {
        Write-Output "${computer}: No such host is known"
    }
}
