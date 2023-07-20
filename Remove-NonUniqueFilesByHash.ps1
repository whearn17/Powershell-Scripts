# Get all files in the directory
$files = Get-ChildItem -File

# Initialize an empty hash table
$hashTable = @{}

foreach ($file in $files)
{
    # Compute the hash of the file
    $fileHash = (Get-FileHash -Path $file.FullName -ErrorAction SilentlyContinue).Hash

    # Check if the hash is null before proceeding
    if ($null -ne $fileHash) 
    {
        # If the hash is already in the hash table, remove the file
        if ($hashTable.ContainsKey($fileHash))
        {
            Remove-Item -Path $file.FullName -Force
        }
        # If the hash is not in the hash table, add it
        else
        {
            $hashTable.Add($fileHash, $file.FullName)
        }
    }
}
