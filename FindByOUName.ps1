$searchRoot = "redacted"

$OUs = Get-ADOrganizationalUnit -SearchBase $searchRoot -Filter * -SearchScope Subtree

$finalUsers = @()

foreach ($ou in $OUs) {
    if ($ou.Name -eq "redacted") {

        $users = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName

        Write-Output "`nUsers in $($ou.DistinguishedName):`n------------------------------------------------------------------"
        
        foreach ($user in $users) {
            Write-Output " $($user.Name)"

            $isMember = $false

            $groups = Get-ADPrincipalGroupMembership $user.SamAccountName

            foreach ($group in $groups) {
                if ($group.Name -eq "redacted") {
                    $isMember = $true
                }
            }
            $finalUsers += [PSCustomObject]@{
                SamAccountName = $user.SamAccountName
                Enabled = $user.Enabled
                IsMemberOfVPNGroup = $isMember
            }
        }
    }
}

$finalUsers | Select-Object SamAccountName, Enabled, IsMemberOfVPNGroup | Export-Csv -Path .\export\redacted.csv -NoTypeInformation