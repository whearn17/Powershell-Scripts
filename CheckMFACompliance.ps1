# Define MFA group
[string]$groupName = "redacted"

# Define OU for search filter
[string]$ou = "redacted"

# Define search method
[string]$searchScope = "Subtree"  

# Get list of names to exclude from file
[string[]]$exclusionList = Get-Content ".\ExcludeMFACheck.txt"

# get all users in the specified OU and all sub-OUs
[Microsoft.ActiveDirectory.Management.ADUser[]]$users = Get-ADUser -Filter * -SearchBase $ou -SearchScope $searchScope -Properties MemberOf | Sort-Object Name 

# Check if a user is missing MFA
function CheckIfUserIsMissingMFA([Microsoft.ActiveDirectory.Management.ADUser]$user) {
    if (!($user.MemberOf -like "*$groupName*") -and ($user.Enabled) -and ($exclusionList -notcontains $user.SamAccountName)) {
        return $true
    }
    return $false
}

[Microsoft.ActiveDirectory.Management.ADUser]$missingMFAUsers = $users | Where-Object { CheckIfUserIsMissingMFA $_ }

[int]$missingMFACount = ($missingMFAUsers | Measure-Object).Count

Write-Host "-----------------------"
Write-Host "Missing MFA Users:"
Write-Host "-----------------------" -ForegroundColor Yellow -BackgroundColor Black
$missingMFAUsers | ForEach-Object { Write-Host $_.SamAccountName -ForegroundColor Red }
Write-Host "-----------------------" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "Total Count: $missingMFACount" -ForegroundColor Green
Write-Host "-----------------------"
