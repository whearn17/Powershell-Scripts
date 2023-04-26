$ip = Read-Host "Enter IP address to query"

# Get all available scopes from DHCP server
$scopes = Get-DhcpServerv4Scope -ComputerName "redacted"

# Loop through each scope until we find a lease for the specified IP address
foreach ($scope in $scopes) {
    # Get lease information for current scope
    $leases = Get-DhcpServerv4Lease -ComputerName "redacted" -ScopeId $scope.ScopeId

    # Find lease corresponding to specified IP address
    $lease = $leases | Where-Object { $_.IPAddress -eq $ip }

    # If a lease was found, print additional information and exit loop
    if ($lease) {
        $computerName = $lease.HostName
        $macAddress = $lease.ClientId
        $leaseExpires = $lease.LeaseExpires

        # Print the information to the console
        Write-Host "Computer Name: $computerName"
        Write-Host "MAC Address: $macAddress"
        Write-Host "Lease Expires: $leaseExpires"
        break
    }
}

# If no lease was found, print an error message
if (!$lease) {
    Write-Host "No lease found for IP address $ip"
}
