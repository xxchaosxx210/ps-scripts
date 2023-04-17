

function Show-Main {
    # $PYTHON_VERSION = "Python 3.11" 

    $uri = "https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe"
    
    # $basePath = Split-Path -Path $uri
    $fileName = Split-Path -Path $uri -Leaf
    
    $downloadPath = Join-Path -Path $env:USERPROFILE\Downloads -ChildPath $fileName

    $params = @{
        Uri     = $uri
        OutFile = $downloadPath
    }

    $job = Start-Job -Name "python-download" -ScriptBlock {
        Param($params)
        try {
            Invoke-WebRequest @params
            return "Download complete"
        }
        catch {
            return "Error: $($_.ErrorDetails.Message.ToString())"
        }
    } -ArgumentList $params

    Write-Host "Downloading Python 3.11..."

    if ($job.State -ne "Completed") {
        Write-Host "Job is still running. Waiting on Job..."
        Wait-Job -Job $job
    }

    $jobMessage = Receive-Job -Job $job
    Write-Host $jobMessage

}

Show-Main