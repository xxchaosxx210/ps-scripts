# This function iterates and checks if a enter key has been pressed and exits if so
function Read-Key-Press {
    Param(
        [int]$Timeout
    )
    while ($true) {
        # Check if a Key has been pressed at the keyboard every 100 ms
        if ([System.Console]::KeyAvailable) {
            $keyPressedObject = [System.Console]::ReadKey($true)
            if ($keyPressedObject.Key -eq "Enter") {
                break
            }
            Write-Host "Press 'Enter' Key to exit."
        }
        # put the loop to sleep for a fraction of a second
        Start-Sleep -Milliseconds $Timeout
    }
}

function Show-Main {
    Write-Host "Press 'Enter' key to quit Script: " -NoNewline
    Read-Key-Press -Timeout 100
    Write-Output "`n"
}

Show-Main