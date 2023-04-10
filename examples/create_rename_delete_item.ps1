# in this example will create a new folder, retrieve it and rename and then finally delete it

function Show-Main {
    $folderName = Read-Host "Folder Name to create: "
    # check folder exists
    if ((Test-Path ".\${folderName}") -eq $true) {
        Write-Output "Folder with that name already exists. Exiting..."
        return
    }
    Write-Output "Creating new folder..."
    # create a new directory
    New-Item -Path ".\${folderName}" -ItemType "directory"
    if (!$?) {
        $errorMessage = $Error.ToString()
        Write-Output $errorMessage
        return
    }
    Write-Output "new folder created"
    # change the directory name
    $newFolderName = Read-Host "What would you like to rename the new folder to? "
    $folderObject = Get-ChildItem -Path . | Where-Object { $_.Name -eq $folderName }
    if ($null -eq $folderObject) {
        Write-Output "Could not find Folder with the name ${folderName}"
        return
    }
    Write-Output "Renaming ${folderName} to ${newFolderName}"
    Rename-Item -Path $folderObject.FullName -NewName $newFolderName
    Write-Output "Folder renamed successfully"
    $folderObject = Get-ChildItem -Path . | Where-Object { $_.Name -eq $newFolderName }
    Write-Output $folderObject
    Write-Output "Removing new folder..."
    Remove-Item -Path $folderObject.FullName
    Write-Output "Done"
}


Show-Main