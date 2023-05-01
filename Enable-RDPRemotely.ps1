$computer = ""
$domainUserName = ""
$userToAddToRDP = ""


Invoke-Command -ComputerName $computer -Credential $domainUserName -ArgumentList $userToAddToRDP -ScriptBlock {
    function EnableRDP ($userToAddToRDP) {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $userToAddToRDP
    }

    EnableRDP $args[0]
}