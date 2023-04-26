Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(800,600)
$form.Text = "Active Directory Users"
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Size = New-Object System.Drawing.Size(200,480)
$listBox.Location = New-Object System.Drawing.Point(10,50)
$listBox.SelectionMode = [System.Windows.Forms.SelectionMode]::One

$labelUsername = New-Object System.Windows.Forms.Label
$labelUsername.Size = New-Object System.Drawing.Size(100,30)
$labelUsername.Location = New-Object System.Drawing.Point(220,10)
$labelUsername.Text = "Username:"

$textBoxUsername = New-Object System.Windows.Forms.TextBox
$textBoxUsername.Size = New-Object System.Drawing.Size(200,30)
$textBoxUsername.Location = New-Object System.Drawing.Point(330,10)

$labelDisplayName = New-Object System.Windows.Forms.Label
$labelDisplayName.Size = New-Object System.Drawing.Size(100,30)
$labelDisplayName.Location = New-Object System.Drawing.Point(220,50)
$labelDisplayName.Text = "Display Name:"

$textBoxDisplayName = New-Object System.Windows.Forms.TextBox
$textBoxDisplayName.Size = New-Object System.Drawing.Size(200,30)
$textBoxDisplayName.Location = New-Object System.Drawing.Point(330,50)

$labelEmail = New-Object System.Windows.Forms.Label
$labelEmail.Size = New-Object System.Drawing.Size(100,30)
$labelEmail.Location = New-Object System.Drawing.Point(220,90)
$labelEmail.Text = "Email:"

$textBoxEmail = New-Object System.Windows.Forms.TextBox
$textBoxEmail.Size = New-Object System.Drawing.Size(200,30)
$textBoxEmail.Location = New-Object System.Drawing.Point(330,90)

$labelEnabled = New-Object System.Windows.Forms.Label
$labelEnabled.Size = New-Object System.Drawing.Size(100,30)
$labelEnabled.Location = New-Object System.Drawing.Point(220,130)
$labelEnabled.Text = "Enabled:"

$textBoxEnabled = New-Object System.Windows.Forms.TextBox
$textBoxEnabled.Size = New-Object System.Drawing.Size(200,30)
$textBoxEnabled.Location = New-Object System.Drawing.Point(330,130)

$labelPasswordLastSet = New-Object System.Windows.Forms.Label
$labelPasswordLastSet.Size = New-Object System.Drawing.Size(100,30)
$labelPasswordLastSet.Location = New-Object System.Drawing.Point(220,170)
$labelPasswordLastSet.Text = "PasswordLastSet:"

$textBoxPasswordLastSet = New-Object System.Windows.Forms.TextBox
$textBoxPasswordLastSet.Size = New-Object System.Drawing.Size(200,30)
$textBoxPasswordLastSet.Location = New-Object System.Drawing.Point(330,170)

$labelLockedOut = New-Object System.Windows.Forms.Label
$labelLockedOut.Size = New-Object System.Drawing.Size(100,30)
$labelLockedOut.Location = New-Object System.Drawing.Point(220,210)
$labelLockedOut.Text = "Locked Out:"

$textBoxLockedOut = New-Object System.Windows.Forms.TextBox
$textBoxLockedOut.Size = New-Object System.Drawing.Size(200,30)
$textBoxLockedOut.Location = New-Object System.Drawing.Point(330,210)

$labelSearch = New-Object System.Windows.Forms.Label
$labelSearch.Text = "Search:"
$labelSearch.Location = New-Object System.Drawing.Point(10, 10)
$labelSearch.AutoSize = $true

$textBoxSearch = New-Object System.Windows.Forms.TextBox
$textBoxSearch.Location = New-Object System.Drawing.Point(60, 10)
$textBoxSearch.Width = 130

$form.Controls.Add($listBox)
$form.Controls.Add($labelUsername)
$form.Controls.Add($textBoxUsername)
$form.Controls.Add($labelDisplayName)
$form.Controls.Add($textBoxDisplayName)
$form.Controls.Add($labelEmail)
$form.Controls.Add($textBoxEmail)
$form.Controls.Add($labelEnabled)
$form.Controls.Add($textBoxEnabled)
$form.Controls.Add($labelPasswordLastSet)
$form.Controls.Add($textBoxPasswordLastSet)
$form.Controls.Add($labelLockedOut)
$form.Controls.Add($textBoxLockedOut)
$form.Controls.Add($labelSearch)
$form.Controls.Add($textBoxSearch)

$users = Get-ADUser -Filter * | Sort-Object Name

foreach ($user in $users) {
    $listBox.Items.Add($user.SamAccountName)
}

$listBox.Add_SelectedIndexChanged({
    $selectedUser = $listBox.SelectedItem
    $selectedUser = Get-ADUser -Filter 'SamAccountName -eq $selectedUser' -Properties EmailAddress, PasswordLastSet, LockedOut

    $textBoxUsername.Text = $selectedUser.SamAccountName

    $textBoxDisplayName.Text = $selectedUser.Name

    $textBoxEmail.Text = $selectedUser.EmailAddress

    $textBoxEnabled.Text = $selectedUser.Enabled

    $textBoxPasswordLastSet.Text = $selectedUser.PasswordLastSet

    $textBoxLockedOut.Text = $selectedUser.LockedOut
})

$textBoxSearch.Add_TextChanged({
    $listBox.Items.Clear()
    $searchTerm = $textBoxSearch.Text
    $filteredUsers = $users | Where-Object { $_.SamAccountName -like "*$searchTerm*" }
    foreach ($user in $filteredUsers) {
        $listBox.Items.Add($user.SamAccountName)
    }
})

$form.ShowDialog()
