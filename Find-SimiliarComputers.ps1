# Define a function to compare two computer names and determine if they are similar
function Compare-ComputerNames {
    param (
        [string]$ComputerName1,
        [string]$ComputerName2
    )
    # Initialize the similarity count to 0
    $similarity = 0
    # Loop through each character in the first computer name
    for ($i = 0; $i -lt $ComputerName1.Length; $i++) {
        # If the corresponding character in the second computer name does not match,
        # break out of the loop immediately
        if ($ComputerName1[$i] -ne $ComputerName2[$i]) {
            break
        }
        # Otherwise, increment the similarity count by 1
        $similarity++
    }
    # If the similarity count is greater than or equal to 3,
    # return true to indicate that the computer names are similar,
    # otherwise return false
    if ($similarity -ge 3) {
        return $true
    }
    else {
        return $false
    }
}

# Define a function to group similar computer names together
function Group-SimilarComputers {
    param (
        [string[]]$ComputerNames
    )
    # Initialize an empty hashtable to store the groups
    $groups = @{}
    # Loop through each computer name in the input array
    foreach ($computerName in $ComputerNames) {
        # Loop through each existing group name in the hashtable
        foreach ($groupName in $groups.Keys) {
            # If the current computer name is similar to an existing group name,
            # add the computer name to the corresponding group
            if (Compare-ComputerNames $computerName $groupName) {
                $groups[$groupName] += $computerName
                break
            }
        }
        # If the current computer name is not similar to any existing group names,
        # create a new group for the computer name
        if (-not $groups.ContainsKey($computerName)) {
            $groups[$computerName] = @($computerName)
        }
    }
    # Return an array of arrays containing the groups of similar computer names
    return $groups.Values | Where-Object { $_.Count -gt 1 }
}

# Get all computer names from Active Directory and sort them alphabetically
$computers = Get-ADComputer -Filter * | Sort-Object Name 
$computerNames = $computers.Name

# Group similar computer names together
$groups = Group-SimilarComputers $computerNames

# Print out the groups of similar computer names
foreach ($group in $groups) {
    # The first computer name in the group is used as the group name
    $groupName = $group[0]
    # The number of computer names in the group is counted
    $groupCount = $group.Count
    # The group name and count are combined into a single string
    $groupDisplayName = "$groupName ($groupCount)"
    # Print out the group name and each computer name in the group, indented with two spaces
    Write-Output "Similar computers: $groupDisplayName"
    foreach ($computer in $group) {
        Write-Output "  $computer"
    }
    # Print a blank line to separate the groups
    Write-Output ""
}
