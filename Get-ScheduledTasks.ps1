[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$tasks = Get-ChildItem -Path $Path -Recurse -File | Where-Object {
    $firstLine = Get-Content -Path $_.FullName -TotalCount 1
    $firstLine -match '^<\?xml version="1.0".*\?>'    
}

$taskList = @()

foreach ($task in $tasks) {
    Write-Host "Processing $($task.FullName)"
    $taskXml = [xml](Get-Content -Path $task.FullName)
    $taskName = $taskXml.Task.RegistrationInfo.URI
    $taskPath = $task.FullName
    $taskEnabled = $taskXml.Task.Settings.Enabled
    $taskAuthor = $taskXml.Task.Principals.Principal.UserId
    $taskCreated = $taskXml.Task.RegistrationInfo.Date
    $taskCommand = $taskXml.Task.Actions.Exec.Command
    $taskCommandArguments = $taskXml.Task.Actions.Exec.Arguments
    $taskDescription = $taskXml.Task.RegistrationInfo.Description
    $taskSource = $taskXml.Task.RegistrationInfo.Source

    $taskList += New-Object PSObject -Property @{
        TaskName  = $taskName
        Path      = $taskPath
        Enabled   = $taskEnabled
        Author    = $taskAuthor
        Created   = $taskCreated
        Command   = $taskCommand
        Arguments = $taskCommandArguments
        Description = $taskDescription
        Source = $taskSource
    }
}

$taskList | Export-Csv -Path $Path\ScheduledTasks.csv -NoTypeInformation