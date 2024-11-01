param(
    [Parameter(Mandatory=$true)]
    [string]$outputPath
)

# Define the API URL with a placeholder for the IP address
$apiUrl = "https://pro.ip-api.com/json/{0}?fields=status,country,regionName,city,isp,proxy,hosting&key=BTXJNNReNntviQB"

# Gather TCP connections and associate with processes
$connections = Get-NetTCPConnection -State Established | ForEach-Object {
    $processName = ""
    try {
        $processName = (Get-Process -Id $_.OwningProcess).Name
    }
    catch {
        $processName = "Unknown/Not Found"
    }

    $response = @{}
    if ($_.RemoteAddress -ne '127.0.0.1' -and $_.RemoteAddress -notlike 'fe80::*') {
        $url = $apiUrl -f $_.RemoteAddress
        try {
            $response = Invoke-RestMethod -Uri $url
        }
        catch {
            $response.status = "fail"
        }
    }
    else {
        $response.status = "local"
    }

    [PSCustomObject]@{
        'LocalAddress'      = $_.LocalAddress
        'LocalPort'         = $_.LocalPort
        'RemoteAddress'     = $_.RemoteAddress
        'RemotePort'        = $_.RemotePort
        'State'             = $_.State
        'OwningProcessId'   = $_.OwningProcess
        'OwningProcessName' = $processName
        'Country'           = if ($response.status -eq "success") { $response.country } elseif ($response.status -eq "local") { "Local" } else { "N/A" }
        'Region'            = if ($response.status -eq "success") { $response.regionName } elseif ($response.status -eq "local") { "Local" } else { "N/A" }
        'City'              = if ($response.status -eq "success") { $response.city } elseif ($response.status -eq "local") { "Local" } else { "N/A" }
        'ISP'               = if ($response.status -eq "success") { $response.isp } elseif ($response.status -eq "local") { "Local" } else { "N/A" }
        'Proxy'             = if ($response.status -eq "success") { $response.proxy } elseif ($response.status -eq "local") { "Local" } else { "N/A" }
        'Hosting'           = if ($response.status -eq "success") { $response.hosting } elseif ($response.status -eq "local") { "Local" } else { "N/A" }
    }
}

# Export results to a CSV
$connections | Export-Csv "$($outputPath)current_connections.csv" -NoTypeInformation