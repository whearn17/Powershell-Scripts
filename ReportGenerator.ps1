<#
Author: Will Hearn
Date: 2/6/23
Version: 1.2.0

This program shows a list of all active directory users and 
some of the most common properties one might want to query
from them. It allows you to select the users you want, then
select which properties you want, and generates a report
which is output as a csv file.

#>

Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms

#----------------- Section: Variables -----------------------#

# Path to the temp file for the csv
$tempReportPath = "C:\temp\ADUserReport.csv"

# Get a list of all Active Directory users
$users = Get-ADUser -Filter * | Sort-Object Name

# Get a list of all Active Directory groups
$groups = Get-ADGroup -Filter * | Select-Object Name | Sort-Object Name

#------------------- Section: Group Select Window ---------------------#

# Window for selecting users by group or name
$userFilterForm = New-Object System.Windows.Forms.Form
$userFilterForm.Size = New-Object System.Drawing.Size(220, 300)
$userFilterForm.Text = "Select Users"

# Listbox for showing all Active Directory groups
$groupListBox = New-Object System.Windows.Forms.ListBox
$groupListBox.Size = New-Object System.Drawing.Size(180, 200)
$groupListBox.Location = New-Object System.Drawing.Point(10, 10)
$groupListBox.SelectionMode = [System.Windows.Forms.SelectionMode]::One
$userFilterForm.Controls.Add($groupListBox)

# Button for selecting all users in selected group
$addGroupButton = New-Object System.Windows.Forms.Button
$addGroupButton.Location = New-Object System.Drawing.Point(10, 220)
$addGroupButton.Size = New-Object System.Drawing.Size(100, 30)
$addGroupButton.Text = "Add Group"
$userFilterForm.Controls.Add($addGroupButton)

# Logic for group selection button
$addGroupButton.Add_Click(
    {
        $selectedGroup = $groupListBox.SelectedItem
        $group = Get-ADGroup -Identity $selectedGroup | Select-Object -ExpandProperty DistinguishedName
        $groupUsers = Get-ADUser -Filter { Memberof -eq $group }
        foreach ($user in $groupUsers) 
        {
            Write-Host $user.SamAccountName
            if ($userSelectBox.Items.Contains($user.SamAccountName)) 
            {
                $index = $userSelectBox.Items.IndexOf($user.SamAccountName)
                $userSelectBox.SelectedIndex = $index
            }
        }
    }
)

#----------------------------  Section: Main Window --------------------------------#

# Main window
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(500, 550)
$form.Text = "Active Directory User Report Generator"

# This is the main list box where users are selected
$userSelectBox = New-Object System.Windows.Forms.ListBox
$userSelectBox.Location = New-Object System.Drawing.Point(10, 60)
$userSelectBox.Size = New-Object System.Drawing.Size(200, 400)
$userSelectBox.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiSimple
$form.Controls.Add($userSelectBox)

# This button selects all users
$selectAllButton = New-Object System.Windows.Forms.Button
$selectAllButton.Location = New-Object System.Drawing.Point(10, 470)
$selectAllButton.Size = New-Object System.Drawing.Size(100, 30)
$selectAllButton.Text = "Select All"
$form.Controls.Add($selectAllButton)

# Logic for button that selects all users
$selectAllButton.Add_Click(
    {
        $userSelectBox.SelectedIndex = -1 # Clear current selection
        for ($i = 0; $i -lt $userSelectBox.Items.Count; $i++) {
            $userSelectBox.SetSelected($i, $true)
        }
    }
)

# This button deselects all users
$deSelectAllButton = New-Object System.Windows.Forms.Button
$deSelectAllButton.Location = New-Object System.Drawing.Point(110, 470)
$deSelectAllButton.Size = New-Object System.Drawing.Size(100, 30)
$deSelectAllButton.Text = "Deselect All"
$form.Controls.Add($deSelectAllButton)

# Logic for button that deselects all users
$deSelectAllButton.Add_Click(
    {
        $userSelectBox.SelectedIndex = -1 # Clear current selection
    }
)

# Listbox for Active Directory user properties
$propertySelectBox = New-Object System.Windows.Forms.CheckedListBox
$propertySelectBox.Location = New-Object System.Drawing.Point(250, 10)
$propertySelectBox.Size = New-Object System.Drawing.Size(200, 450)
$form.Controls.Add($propertySelectBox)

# Add user properties to the checked listbox
$propertySelectBox.Items.Add("Name")
$propertySelectBox.Items.Add("Enabled")
$propertySelectBox.Items.Add("PasswordLastSet")
$propertySelectBox.Items.Add("LastLogonDate")
$propertySelectBox.Items.Add("EmailAddress")
$propertySelectBox.Items.Add("SID")
$propertySelectBox.Items.Add("SamAccountName")

# Button for opening window to select users by group
$selectUserBy = New-Object System.Windows.Forms.Button
$selectUserBy.Location = New-Object System.Drawing.Point(10, 20)
$selectUserBy.Size = New-Object System.Drawing.Size(140, 30)
$selectUserBy.Text = "Select By Group"
$form.Controls.Add($selectUserBy)

# Group select window button logic
$selectUserBy.Add_Click(
    {
        $userFilterForm.ShowDialog()
    }
)

# This button generates the report
$generateButton = New-Object System.Windows.Forms.Button
$generateButton.Location = New-Object System.Drawing.Point(250, 470)
$generateButton.Size = New-Object System.Drawing.Size(200, 30)
$generateButton.Text = "Generate Report"

# Logic for generating report
$generateButton.Add_Click(
    {
        # Get selected users and properties
        $selectedUsers = $userSelectBox.SelectedItems
        $selectedProperties = $propertySelectBox.CheckedItems

        # Create table
        $users = @()

        # Loop through selected users
        foreach ($selectedUser in $selectedUsers) 
        {
            $encodedUser = [System.Security.SecurityElement]::Escape($selectedUser)
            $user = Get-ADUser -Filter "SamAccountName -eq '$encodedUser'" -Properties $selectedProperties
            $users += $user
        }

        # Export the report data to a CSV file
        $users | Select-Object $selectedProperties | Export-Csv -Path $tempReportPath -NoTypeInformation

        # Create Excel Object
        $Excel = New-Object -ComObject Excel.Application
        $Excel.Visible = $False
        $Workbook = $Excel.Workbooks.Open($tempReportPath)
        $Sheet = $Workbook.Worksheets.Item(1)   

        # Autofit columns
        $Sheet.Columns.EntireColumn.AutoFit()

        # Create a table with headers
        $Range = $Sheet.Range("A1").CurrentRegion
        $Table = $Sheet.ListObjects.Add(1, $Range, $True)
        $Table.Name = "ADUser Report"
        $Table.TableStyle = "TableStyleMedium2"

        # Save as XLSX in the current directory
        $CurrentDirectory = (Get-Location).Path
        $SavePath = Join-Path $CurrentDirectory "ADUserReport.xlsx"
        $Workbook.SaveAs($SavePath, 51)
        $Excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)

        # Clean up CSV if it exists
        if (Test-Path $tempReportPath) {
            Write-Output "Removing Temp File..."
            Remove-Item $tempReportPath
        }

    }
)

# Add all users to user selection box
foreach ($user in $users) 
{
    $userSelectBox.Items.Add($user.SamAccountName)
}

# Add all groups to group selection box
foreach ($group in $groups) 
{
    $groupListBox.Items.Add($group.Name)
}

$form.Controls.Add($generateButton)
$form.ShowDialog()