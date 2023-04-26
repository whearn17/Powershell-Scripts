# Get the last time the computer was seen online
Get-ADComputer -Filter {enabled -eq $true} -Properties Name, LastLogonTimeStamp |
Select-Object Name, @{Name = "LastLogon"; Expression = { [DateTime]::FromFileTime($_.LastLogonTimeStamp) } } | 
Sort-Object LastLogon |
Format-Table Name, LastLogon


