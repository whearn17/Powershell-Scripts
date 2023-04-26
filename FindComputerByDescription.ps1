# Enter your serial number in $serial

# Entire serial number or portion of serial number
$findInDescription = "redacted"

# All ad computers
$computers = Get-ADComputer -Filter * -Properties Description | Sort-Object Name

# Keep track of how many computers found
$count = 0

# Check each computer for serialnumber in description
foreach($computer in $computers)
{
    if ($computer.Description -match $findInDescription)
    {
        Write-Host $computer.Name '->' $computer.Description `n
        $count ++
    }
}

# Notify if no pcs are found or not
if ($count -lt 1)
{
    Write-Host "No computers found matching serial number"
}
else 
{
    Write-Host "'$count' Computers found"
}