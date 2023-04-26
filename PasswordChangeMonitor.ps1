<#
Author: Will Hearn
Date: 8/22/22
Version: 1.0.2

This script gathers a list of users from a group called "redacted". It then determines whether the users 
passwords have been changed since a specific date. To change this date, edit the "$date" variable.

HOW TO USE: Let's say that you have a company password reset and you would like to monitor how many people
have changed their passwords since the official reset start. You would set the date variable to the date
of the beginning of the password reset and the script will count who has changed their password after that. 

*: Remember that this script only gathers from users in the "redacted" group. If you want information from a different 
group, change the "redacted" text inside of the "$redacted" variable to the group you want.
#>

$redacted = Get-ADGroup -Identity "redacted" | Select-Object -ExpandProperty DistinguishedName
$date = "2/1/2023"

$usercount = (Get-ADUser -Filter {Memberof -eq $redacted -and PasswordLastSet -gt $date}).count
$redactedusers = Get-ADUser -Filter {Memberof -eq $redacted -and PasswordLastSet -gt $date} -Properties PasswordLastSet | Sort-Object passwordlastset | Format-Table Name | Out-String

Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Window icon
$Icon = New-Object system.drawing.icon ("C:\Users\whearn\OneDrive - Cramer\Documents\scripts\wsus.ico")

# Center the screen
$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Main screen object
$TitleScreen = New-Object System.Windows.Forms.Form
$TitleScreen.Text = 'Live Password Count'
$TitleScreen.Icon = $Icon
$TitleScreen.Width = 370
$TitleScreen.Height = 500
$TitleScreen.BackColor = "#b2bec3"
$TitleScreen.AutoSize = $True
$TitleScreen.FormBorderStyle = 'Fixed3D'
$TitleScreen.MaximizeBox = $False
$TitleScreen.StartPosition = $CenterScreen

# Label that specifies that what you are looking at is # of password changes
$Count = New-Object System.Windows.Forms.Label
$Count.Text = 'Password Changes!'
$Count.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 22, [System.Drawing.FontStyle]::Bold)
$Count.Width = 300
$Count.Height = 50
$Count.Location = New-Object System.Drawing.Point(45,40)
$TitleScreen.Controls.Add($Count)

# Creating a label object to show # of users that have changed password
$Number = New-Object System.Windows.Forms.Label
$Number.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 20, [System.Drawing.FontStyle]::Bold)
$Number.Width = 80
$Number.Height = 30
$Number.Location = New-Object System.Drawing.Point(160,90)
$TitleScreen.Controls.Add($Number)

# Creating the output box object
$Output = New-Object System.Windows.Forms.TextBox
$Output.Multiline = $True
$Output.WordWrap = $False
$Output.ReadOnly = $True
$Output.Scrollbars = "Vertical"
$Output.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)
$Output.Text = ""
$Output.Location  = New-Object System.Drawing.Point(60,200)
$Output.Size = New-Object System.Drawing.Size(235,230)
$Output.AutoSize = $true
$TitleScreen.Controls.Add($Output)

# Creating the button object
$Refresh = New-Object System.Windows.Forms.Button
$Refresh.Location = New-Object System.Drawing.Point(60,140)
$Refresh.Size = New-Object System.Drawing.Size(235,50)
$Refresh.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",18,[System.Drawing.FontStyle]::Bold)
$Refresh.Text = "Refresh"
$Refresh.BackColor = "#d63031"
$TitleScreen.Controls.Add($Refresh)

# This function handles what happens when the user presses a button
$Refresh.Add_Click(
{
    $usercount = (Get-ADUser -Filter {Memberof -eq $redacted -and PasswordLastSet -gt $date}).count
    $redactedusers = Get-ADUser -Filter {Memberof -eq $redacted -and PasswordLastSet -gt $date} -Properties PasswordLastSet | Sort-Object PasswordLastSet | Format-Table Name | Out-String

    $Number.Text = "$usercount"
    $Number.Refresh()

    $Output.Text = "$redactedusers"
    $Output.Refresh()
})

$Number.Text = "$usercount"
$Output.Text = "$redactedusers"
$TitleScreen.ShowDialog()