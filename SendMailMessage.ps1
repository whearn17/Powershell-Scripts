$outlook = New-Object -comObject Outlook.Application
$recipients = Get-Content "recipient_list.txt"
$count = 0

$recipients | ForEach-Object {
    $recipient = $_
    try {
        $email = $outlook.CreateItem(0)
        $email.Subject = "Test email from PowerShell"
        $email.Body = "This is a test email sent from PowerShell using the Outlook COM object. Count: $count"
        $email.To = $recipient
        $email.Send()
        
        $count++

        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($email) | Out-Null

        Write-Progress -Activity "Sending emails" -Status "Sent email to: $recipient" -PercentComplete (($count / $recipients.Count) * 100)
    } 
    catch {
        Write-Error "Error sending email to $recipient"
    }
}
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook) | Out-Null
