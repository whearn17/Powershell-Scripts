Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen

$Icon = New-Object system.drawing.icon ("redacted")

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }

$TitleScreen = New-Object System.Windows.Forms.Form
$TitleScreen.Text = 'ADToolz'
$TitleScreen.Icon = $Icon
$TitleScreen.Width = 370
$TitleScreen.Height = 400
$TitleScreen.AutoSize = $True
$TitleScreen.FormBorderStyle = 'Fixed3D'
$TitleScreen.MaximizeBox = $False
$TitleScreen.StartPosition = $CenterScreen

$Watermark = New-Object System.Windows.Forms.Label
$Watermark.Text = 'Made by Will'
$Watermark.Width = 70
$Watermark.Location = New-Object System.Drawing.Point(280,400)
$TitleScreen.Controls.Add($Watermark)

$SingleUserQueryOption = New-Object System.Windows.Forms.Button
$SingleUserQueryOption.Location = New-Object System.Drawing.Point(60,70)
$SingleUserQueryOption.Size = New-Object System.Drawing.Size(240,66)
$SingleUserQueryOption.Font = New-Object System.Drawing.Font("Sans Serif",15,[System.Drawing.FontStyle]::Regular)
$SingleUserQueryOption.Text = "Single User Query"
$TitleScreen.Controls.Add($SingleUserQueryOption)

$MultiUserQueryOption = New-Object System.Windows.Forms.Button
$MultiUserQueryOption.Location = New-Object System.Drawing.Point(60,140)
$MultiUserQueryOption.Size = New-Object System.Drawing.Size(240,66)
$MultiUserQueryOption.Font = New-Object System.Drawing.Font("Sans Serif",15,[System.Drawing.FontStyle]::Regular)
$MultiUserQueryOption.Text = "Multi User Query"
$TitleScreen.Controls.Add($MultiUserQueryOption)

$SingleUserQueryOption.Add_Click(
{
    $Users = Get-ADUser -filter * -Properties SamAccountName
    $RandomUser = Get-ADUser -Filter * -Properties * | Sort-Object{Get-Random} | Select-Object -First 1 | Get-Member -MemberType Property

    foreach ($User in $Users)
    {
        $UserSelect.Items.Add($User.SamAccountName)
    }

    foreach ($Property in $RandomUser)
    {
        $PropertySelect.Items.Add($Property.Name)
    }
    $SingleUserQuery.ShowDialog()
}
)

$MultiUserQueryOption.Add_Click(
{
    $RandomUser = Get-ADUser -Filter * -Properties * | Sort-Object{Get-Random} | Select-Object -First 1 | Get-Member -MemberType Property

    foreach ($Property in $RandomUser)
    {
        $PropertySelect2.Items.Add($Property.Name)
    }
    $MultiUserQuery.ShowDialog()
}
)

#-----------------------------------------------------------------------------------------------------------#

$SingleUserQuery = New-Object System.Windows.Forms.Form
$SingleUserQuery.Text = 'SingleUserQuery'
$SingleUserQuery.Icon = $Icon
$SingleUserQuery.Width = 370
$SingleUserQuery.Height = 400
$SingleUserQuery.FormBorderStyle = 'Fixed3D'
$SingleUserQuery.MaximizeBox = $False
$SingleUserQuery.AutoSize = $true
$SingleUserQuery.StartPosition = $CenterScreen

$UserSelect = New-Object System.Windows.Forms.ComboBox
$UserSelect.Width = 300
$UserSelect.Location  = New-Object System.Drawing.Point(30,10)
$SingleUserQuery.Controls.Add($UserSelect)

$PropertySelect = New-Object System.Windows.Forms.ComboBox
$PropertySelect.Width = 300
$PropertySelect.Location  = New-Object System.Drawing.Point(30,40)
$SingleUserQuery.Controls.Add($PropertySelect)

$Output = New-Object System.Windows.Forms.TextBox
$Output.Multiline = $True
$Output.WordWrap = $False
$Output.ReadOnly = $True
$Output.Scrollbars = "Vertical"
$Output.Text = ""
$Output.Location  = New-Object System.Drawing.Point(30,100)
$Output.Size = New-Object System.Drawing.Size(300,250)
$Output.AutoSize = $true
$SingleUserQuery.Controls.Add($Output)


$QueryButton = New-Object System.Windows.Forms.Button
$QueryButton.Location = New-Object System.Drawing.Point(30,70)
$QueryButton.Size = New-Object System.Drawing.Size(120,23)
$QueryButton.Text = "Query"
$SingleUserQuery.Controls.Add($QueryButton)

$QueryButton.Add_Click(
{
    $Output.Text = ""
    $Properties = Get-ADUser $UserSelect.SelectedItem -Properties $PropertySelect.SelectedItem | Format-Table Name, $PropertySelect.SelectedItem -AutoSize| Out-String 
    $Output.AppendText(($Properties + "`n"))
}
)

#-----------------------------------------------------------------------------------------------------------#

$MultiUserQuery = New-Object System.Windows.Forms.Form
$MultiUserQuery.Text = 'MultiUserQuery'
$MultiUserQuery.Icon = $Icon
$MultiUserQuery.Width = 370
$MultiUserQuery.Height = 400
$MultiUserQuery.AutoSize = $True
$MultiUserQuery.FormBorderStyle = 'Fixed3D'
$MultiUserQuery.MaximizeBox = $False
$MultiUserQuery.StartPosition = $CenterScreen

$MultiUserInput = New-Object System.Windows.Forms.TextBox
$MultiUserInput.Location = New-Object System.Drawing.Point(190,280)
$MultiUserInput.Width = 120
$MultiUserInput.Text = ""
$MultiUserQuery.Controls.Add($MultiUserInput)

$ExportToCSVButton = New-Object System.Windows.Forms.Button
$ExportToCSVButton.Location = New-Object System.Drawing.Point(0,320)
$ExportToCSVButton.Size = New-Object System.Drawing.Size(120,23)
$ExportToCSVButton.Text = "Export to CSV"
$MultiUserQuery.Controls.Add($ExportToCSVButton)

$QueryButton2 = New-Object System.Windows.Forms.Button
$QueryButton2.Location = New-Object System.Drawing.Point(190,320)
$QueryButton2.Size = New-Object System.Drawing.Size(120,23)
$QueryButton2.Text = "Query"
$MultiUserQuery.Controls.Add($QueryButton2)

$LessThanGreaterThan = New-Object System.Windows.Forms.Button
$LessThanGreaterThan.Location = New-Object System.Drawing.Point(140,280)
$LessThanGreaterThan.Size = New-Object System.Drawing.Size(30,23)
$LessThanGreaterThan.Text = ">"
$MultiUserQuery.Controls.Add($LessThanGreaterThan)

$PropertySelect2 = New-Object System.Windows.Forms.ComboBox
$PropertySelect2.Width = 120
$PropertySelect2.Location  = New-Object System.Drawing.Point(0,280)
$MultiUserQuery.Controls.Add($PropertySelect2)

$Output2 = New-Object System.Windows.Forms.TextBox
$Output2.Multiline = $True
$Output2.WordWrap = $False
$Output2.ReadOnly = $True
$Output2.Scrollbars = "Vertical"
$Output2.Text = ""
$Output2.Location  = New-Object System.Drawing.Point(0,0)
$Output2.Size = New-Object System.Drawing.Size(300,270)
$Output2.AutoSize = $true
$MultiUserQuery.Controls.Add($Output2)

$ExportToCSVButton.Add_Click(
{
    [void]$FileBrowser.ShowDialog()
}
)

$LessThanGreaterThan.Add_Click(
{
    if ($LessThanGreaterThan.Text -contains ">")
    {
        $LessThanGreaterThan.Text = "<"
    }
    else
    {
        $LessThanGreaterThan.Text = ">"
    }
}
)

$QueryButton2.Add_Click(
{
    $Comparison = ""
    if ($LessThanGreaterThan.Text -contains ">")
    {
        $Comparison = "-gt"
    }
    elseif ($LessThanGreaterThan.Text -contains "<")
    {
        $Comparison = "-lt"
    }
    Get-ADUser -Filter (-Property $PropertySelect2.SelectedItem $Comparison $MultiUserInput.Text)
}
)

#-----------------------------------------------------------------------------------------------------------# Main

$TitleScreen.ShowDialog()