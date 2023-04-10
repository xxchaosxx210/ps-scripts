# This script allows to backup pictures in the pictures home folder with a prefix name


# 1. get the Pictures full path from the Home Path enviroment variable
# 2. search the path for images (check extension and add to array)

function Get-Images-From-Path {
    Param(
        [string]$Path
    )
    $imageFiles = Get-ChildItem -Path $Path -Recurse -File -Include *.jpg, *.png, *.webm, *.gif, *.bmp
    return $imageFiles
}

function New-Backup-Path {
    Param(
        [string]$BackupPath
    )
    if ((Test-Path -Path $BackupPath) -eq $true) {
        Write-Host "Backup path with that name already exists"
        return $false
    }
    try {
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
    Param(
        [string]$BackPath,
        [string[]]$SourceFilePaths
    )
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
    # get the full path of the my pictures special folder using the enumerated type
    # check the .NET documentation of GetFolderPath
    $MY_PICTURES_PATH = [System.Environment]::GetFolderPath([Environment+SpecialFolder]::MyPictures)
    $prefixPathName = Read-Host "Prefix Backup Name? "
    $backupPath = Join-Path $MY_PICTURES_PATH $prefixPathName
    $newPathResult = New-Backup-Path -BackupPath $backupPath
    if ($newPathResult -eq $false) {
        Write-Output "Could not create Backup Directory"
        return
    }
    $imageFiles = Get-Images-From-Path -Path $MY_PICTURES_PATH
    $copyCount = Copy-Pictures-To-Backup-Path -BackPath $backupPath -SourceFilePaths $imageFiles
    if ($copyCount -eq 0) {
        return
    }
    # compress the files
    $zipBackupPath = $backupPath + ".zip"
    try {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($backupPath, $zipBackupPath)
    }
    catch {
        Write-Error "Error creating zip file: $_"
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

Show-Main