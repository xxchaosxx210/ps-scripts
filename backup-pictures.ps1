function Get-Images-From-Path {
    <#
    .PARAMETER Path
    The path to search for images.
    .NOTES
    Returns an array of files that are images, recursively from the input path.
    #>
    Param(
        [string]$Path
    )
    $imageFiles = Get-ChildItem -Path $Path -Recurse -File -Include *.jpg, *.png, *.webm, *.gif, *.bmp
    return $imageFiles
}

function New-Backup-Path {
    <#
    .PARAMETER BackupPath
    The name of the directory that will be created for backups.
    .NOTES
    Creates a new directory for backup if one with the same name doesn't exist.
    #>
    Param(
        [string]$BackupPath
    )
    # check the pathname does not exist before proceeding
    if ((Test-Path -Path $BackupPath) -eq $true) {
        Write-Host "Backup path with that name already exists"
        return $false
    }
    try {
        # create the new path
        New-Item -Path $BackupPath -ItemType "directory"
        return $true
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error "Error creating Backup Path: $_"
        return $false
    }
}

function Copy-Pictures-To-Backup-Path {
    <#
    .PARAMETER BackPath
    The path where the backup will be stored.
    .PARAMETER SourceFilePaths
    An array of source paths for the pictures.
    .NOTES
    Copies pictures from source paths to a backup directory.
    #>
    Param(
        [string]$BackPath,
        [string[]]$SourceFilePaths
    )
    # keep track of the amount of files copied
    $counter = 0
    foreach ($sourceFilePath in $SourceFilePaths) {
        # split the filename from the path and append to the back path
        $fileName = Split-Path $sourceFilePath -Leaf -Resolve
        $backupFilePath = Join-Path $BackPath $fileName
        # copy the picture into the backup directory
        try {
            Copy-Item $sourceFilePath -Destination $backupFilePath
            $counter++
        }
        catch {
            Write-Error "Error Copying File: $_"
        }
    }
    return $counter
}


function Show-Main {
    <#
    .NOTES
    Main function that drives the whole process of creating backups for pictures.
    #>
    # get the full path of the my pictures special folder using the enumerated type
    # check the .NET documentation of GetFolderPath
    $MY_PICTURES_PATH = [System.Environment]::GetFolderPath([Environment+SpecialFolder]::MyPictures)
    # prompt for backup pathname
    $prefixPathName = Read-Host "Prefix Backup Name? "
    # create the full backup path
    $backupPath = Join-Path $MY_PICTURES_PATH $prefixPathName
    $newPathResult = New-Backup-Path -BackupPath $backupPath
    if ($newPathResult -eq $false) {
        Write-Output "Could not create Backup Directory"
        return
    }
    # get all image files from the pictures directory and copy them all to the backup path
    $imageFiles = Get-Images-From-Path -Path $MY_PICTURES_PATH
    $copyCount = Copy-Pictures-To-Backup-Path -BackPath $backupPath -SourceFilePaths $imageFiles
    if ($copyCount -eq 0) {
        return
    }
    # zip the backup path
    $zipBackupPath = $backupPath + ".zip"
    Write-Output "Creating Backup Zip: ${zipBackupPath}..."
    try {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($backupPath, $zipBackupPath)
    }
    catch {
        Write-Error "Error creating zip file: $_"
        return
    }
    # remove the backup folder and its contents
    try {
        Remove-Item $backupPath -Recurse -Force
        Write-Output "Removing Backup Folder..."
    }
    catch {
        Write-Error "Error removing backup folder: $_"
    }
    Write-Output "Backup created and compressed!"
}

# load the .NET library for compressing files
Add-Type -AssemblyName System.IO.Compression.FileSystem

# call the main function
Show-Main