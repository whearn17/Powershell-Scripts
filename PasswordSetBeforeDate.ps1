<#
Author: Will Hearn
Date: 1/31/23
Version: 1.0.0

This script collects redacted user accounts from a group called "redacted" and checks to see if they have 
changed their password since the set date. To get a list of users who haven't changed their password 
since a certain date, put the date you want inside of the "$date" variable. 

HOW TO USE: Let's say that you want to find out who hasn't changed their password since x/x/x (date). 
Put that date inside of the "$date" variable and run the script. It will return redacted the users that haven't
changed their passwords after that date.
#>

# Create redacted group object
$redacted = Get-ADGroup -Identity "redacted" | Select-Object -ExpandProperty DistinguishedName

# Pick a date to compare to password last set
$date = "10/1/2022 08:00:00AM"

# Find users in the redacted group that haven't changes their password after the set date
Get-ADUser -Filter { memberof -eq $redacted -and PasswordLastSet -lt $date } -Properties PasswordLastSet | Select-Object Name, PasswordLastSet | Sort-Object Name | Format-Table Name, passwordlastset

# Find users in the redacted group that haven't changes their password after the set date -> transform to number
(Get-ADUser -Filter { memberof -eq $redacted -and PasswordLastSet -lt $date }  | Sort-Object Name | Format-Table Name).count

# Export to csv
Get-ADUser -Filter { memberof -eq $redacted -and PasswordLastSet -lt $date } -Properties PasswordLastSet | Select-Object Name, PasswordLastSet | Sort-Object Name | Export-Csv "UsersNotReset.csv"