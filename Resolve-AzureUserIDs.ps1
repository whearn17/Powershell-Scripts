# Connect to Azure AD
Connect-AzureAD

# Fetch users and store in a variable
$users = Get-AzureADUser -All $true

# Format the output
$output = $users | ForEach-Object { "$($_.ObjectId)`t$($_.UserPrincipalName)" }

# Copy to clipboard
$output | Set-Clipboard

# Print a confirmation
Write-Host "User details copied to clipboard!" -ForegroundColor Green