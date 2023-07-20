Connect-ExchangeOnline

# Get all mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Define an array to store the result
$results = @()

# For each mailbox, get permissions
foreach ($mailbox in $mailboxes) {
    $permissions = Get-MailboxPermission -Identity $mailbox.UserPrincipalName |
    Where-Object { ($_.IsInherited -eq $False) -and ($_.User -notlike "NT AUTHORITY\SELF") -and ($_.User -notlike "S-*") } |
    Select-Object @{Name='Mailbox';Expression={$mailbox.UserPrincipalName}}, User, AccessRights

    # Add the result to the array
    $results += $permissions
}

# Export the result to CSV
$results | Export-Csv -Path 'MailboxPermissions.csv' -NoTypeInformation