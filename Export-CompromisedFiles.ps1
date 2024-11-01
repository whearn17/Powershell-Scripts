# Connect to Exchange Online PowerShell
Connect-ExchangeOnline -ShowBanner:$false 

# Prompt for the paths to the lists of subjects and mailboxes
$subjectsPath = Read-Host -Prompt "Enter the path to the subjects file"
$mailboxesPath = Read-Host -Prompt "Enter the path to the mailboxes file"

# Read the lists of subjects and mailboxes
$subjects = Get-Content $subjectsPath | ForEach-Object { $_.TrimEnd() }
$mailboxes = Get-Content $mailboxesPath

# Create the search query for the subjects
$subjectQuery = $subjects -join "' OR Subject:'"
$subjectQuery = "Subject:'$subjectQuery'"

# Set up and start the eDiscovery search
New-MailboxSearch -Name "TestSearchCompromisedFiles" -SourceMailboxes $mailboxes -SearchQuery $subjectQuery -EstimateOnly -Force
