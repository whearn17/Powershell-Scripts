$caseDirectories = @(
"Azure_Export",
"Working_Tree",
"Mailbox_Export",
"Message_Trace",
"Hawk",
"Sharepoint_Onedrive",
"Raven",
"MFA",
"Compromised_Files_Export",
"Exchange_Permissions"
)

Write-Host "Enter Case Name: " -NoNewline
$caseName = Read-Host

mkdir $caseName

Set-Location $caseName

foreach ($directory in $caseDirectories) {
    mkdir $directory
}