function Get-PerUserMFAStatus {

    [CmdletBinding(DefaultParameterSetName='All')]
    param(
        [string[]]$UserPrincipalName,
        [switch]$All
    )

    BEGIN {
        if (-not (Get-MsolDomain -ErrorAction SilentlyContinue)) {
            Write-Host "Connecting to MSolService..."
            Connect-MsolService
        }
    }

    PROCESS {
        $MsolUserList = if ($UserPrincipalName) {
            $UserPrincipalName | ForEach-Object {
                Get-MsolUser -UserPrincipalName $_ -ErrorAction Stop
            }
        } else {
            Get-MsolUser -All -ErrorAction Stop | Where-Object {
                $_.UserType -ne 'Guest' -and $_.DisplayName -notmatch 'On-Premises Directory Synchronization'
            }
        }

		$MsolUserList | ForEach-Object {
            $AccountEnabled = $_.BlockCredential -eq $false
            $PerUserMFAState = if ($AccountEnabled -and $_.StrongAuthenticationRequirements) {
                $_.StrongAuthenticationRequirements.State
            } elseif ($AccountEnabled) {
                'Disabled'
            } else {
                'Account Disabled'
            }

            $MethodType = if ($AccountEnabled) {
                $_.StrongAuthenticationMethods | Where-Object {
                    $_.IsDefault -eq $true
                } | Select-Object -ExpandProperty MethodType
            }

            $DefaultMethodType = switch ($MethodType) {
                'OneWaySMS' { 'SMS Text Message' }
                'TwoWayVoiceMobile' { 'Call to Phone' }
                'PhoneAppOTP' { 'TOTP' }
                'PhoneAppNotification' { 'Authenticator App' }
                Default { if ($AccountEnabled) { 'Not Enabled' } else { 'Account Disabled' } }
            }

            [PSCustomObject]@{
                UserPrincipalName = $_.UserPrincipalName
                DisplayName = $_.DisplayName
                PerUserMFAState = $PerUserMFAState
                DefaultMethodType = $DefaultMethodType
                AccountEnabled = $AccountEnabled
            }
        } | Export-Csv -Path "PerUserMFAStatus.csv" -NoTypeInformation -Force
    }
}

Get-PerUserMFAStatus
