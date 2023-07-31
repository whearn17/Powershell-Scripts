function Connect-ExchangeService {
    if (!(Get-ConnectionInformation | Where-Object { $_.Name -match 'ExchangeOnline' -and $_.state -eq 'Connected' })) { 
        Connect-ExchangeOnline -ShowBanner:$false
    }
    else {
        Write-Host "Already connected to Exchange Online"
    }
}

Connect-ExchangeService

# Array to hold all rule details
$allRuleDetails = @()

# Get all users in the tenant
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Loop through each user and get the inbox rules
foreach ($mailbox in $mailboxes) {
    Write-Host "Processing $($mailbox.PrimarySmtpAddress)"
    $inboxRules = Get-InboxRule -Mailbox $mailbox.PrimarySmtpAddress

    # Loop through each rule and get its details
    foreach ($rule in $inboxRules) {
        try {
            $ruleDetails = Get-InboxRule -Identity $rule.Identity
            # Add the rule details to the array
            $allRuleDetails += $ruleDetails
        }
        catch {
            Write-Host "Failed to get rule details for rule $($rule.Identity) for mailbox $($mailbox.PrimarySmtpAddress)"
        }
    }
}

# Export the array to a CSV file
$allRuleDetails | Export-Csv -Path "inbox_rules.csv" -NoTypeInformation