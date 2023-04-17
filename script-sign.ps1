# creates new certificates and signs scripts

# not yet completed


# Globals

$QUIT_SELECTED = -1

<#
.SYNOPSIS
Waits for a key press event at the keyboard and returns the key char type
#>
function Get-Key-Press {
    Param(
        # [Parameter(Mandatory = $true)]
        [double]$Timeout = 0.2
    )
    while ($true) {
        if ([System.Console]::KeyAvailable) {
            # read the key input
            $keyObject = [System.Console]::ReadKey($true)
            return $keyObject.KeyChar
        }
        Start-Sleep -Seconds $Timeout
    }
}

<#
.SYNOPSIS
Takes in an array of PSObjects and an optional escape key character.
The function then enters into an infinite loop and waits for user input.
If the user presses the key that matches the $EscapeKey, the function returns -1.
If the user presses a digit key, the function checks if the value is within the range
of the PSObjects array length and returns the index of the selected object
(minus one to account for zero-based indexing).
This function is designed to allow the user to select an object from an array
by typing in the corresponding number or escape to cancel the selection.
#>
function Get-Selection {
    Param(
        [PSObject[]]$PSObjects,
        [char]$EscapeKey = 'q'
    )
    while ($true) {
        $key = Get-Key-Press
        if ([Char]::IsLetter($key) -and $key -eq $EscapeKey) {
            return $QUIT_SELECTED
        }
        elseif ([Char]::IsDigit($key)) {
            $keyValue = [convert]::ToInt32("$key")
            if ($keyValue -gt 0 -and $keyValue -le $PSObjects.Length) {
                return $($keyValue - 1)
            }
        }
    }
}

function Start-New-Certificate-Process {
    Clear-Host
    Write-Host "Select the Certification Storage Path"
    $certPaths = @("Cert:\CurrentUser\My", "Cert:\LocalMachine\My")
    Write-Host "1. CurrentUser"
    Write-Host "2. LocalMachine"
    Write-Host "Q. Go back"
    Write-Host "Selection: " -NoNewline
    $selectionIndex = Get-Selection -PSObjects $certPaths
    switch ($selectionIndex) {
        -1 {
            # Go Back
            Clear-Host
            return
        }
    }
    $certPath = $certPaths[$selectionIndex]
    while ($true) {
        $name = Read-Host "`nFriendly Name: "
        $cert = Get-ChildItem $certPath | Where-Object { $_.FriendlyName -eq $name }
        if ($cert) {
            Clear-Host
            Write-Host "Entry already exists."
        }
        else {
            break
        }
    }
    $dnsName = Read-Host "DNS Name: "
    Write-Host "Creating Certificate..."
    try {
        New-SelfSignedCertificate -DnsName $dnsName -FriendlyName $name -Subject 
    }
    catch {
        Write-Error "Error: $_"
    }
}

function Show-Cert-Store-Certificates {
    Write-Host "---------------------------------------------"
    Write-Host "CurrentUser Certificates"
    Write-Host "---------------------------------------------"
    Get-ChildItem Cert:\CurrentUser\My | Format-List -Property FriendlyName
    Write-Host "---------------------------------------------"
    Write-Host "LocalMachine Certificates"
    Write-Host "---------------------------------------------"
    Get-ChildItem Cert:\LocalMachine\My | Format-List -Property FriendlyName
    Write-Host "---------------------------------------------"
    Write-Host "`n<--- Press 'q' to go back: " -NoNewline
    while ((Get-Key-Press) -ne 'q') {
        Write-Host "`n<--- Press 'q' to go back: " -NoNewline
    }
}

<#
.SYNOPSIS
Displays the certificate menu and waits for user input
#>
function Show-Certificate-Menu {

    $SELECTION_NEW_CERTIFICATE = 0
    $SELECTION_DELETE_CERTIFICATE = 1
    $SELECTION_SHOW_CERTIFICATES = 2

    $SELECTIONS = (
        $SELECTION_NEW_CERTIFICATE, 
        $SELECTION_DELETE_CERTIFICATE, 
        $SELECTION_SHOW_CERTIFICATES
    )

    while ($true) {
        Write-Host "Certificate Menu"
        Write-Host "1. New Certificate"
        Write-Host "2. Delete Certificate"
        Write-Host "3. List Certificates"
        Write-Host "Q. Go Back"
        # list availible certificates
        Write-Host "Selection: " -NoNewline
        $index = Get-Selection -PSObjects $SELECTIONS
        switch ($index) {
            $QUIT_SELECTED {
                return
            }
            $SELECTION_NEW_CERTIFICATE { 
                Start-New-Certificate-Process
            }
            $SELECTION_DELETE_CERTIFICATE {
                Write-Host "Delete Certificate"
            }
            $SELECTION_SHOW_CERTIFICATES {
                Show-Cert-Store-Certificates
            }
            Default {
                throw "Error: Index out of range"
            }
        }
    }

}

<#
.SYNOPSIS
Displays the main menu and waits for user input
#>
function Show-Main {
    $SELECTION_CERTIFICATE_MENU = 0

    while ($true) {
        Clear-Host
        Write-Host "Self Signed Script Signture Creation and Removal"
        Write-Host "1. Certificate Menu"
        Write-Host "Q. Quit"
        Write-Host "Selection: " -NoNewline
        $index = Get-Selection -PSObjects @($SELECTION_CERTIFICATE_MENU)
        switch ($index) {
            $QUIT_SELECTED { 
                return
            }
            $SELECTION_CERTIFICATE_MENU {
                try {
                    Clear-Host
                    Show-Certificate-Menu
                }
                catch {
                    Write-Error "Error in Show-Certificate-Menu: $_"
                }
            }
            Default {
                throw "Error: Index out of range"
            }
        }
    }

}

try {
    Show-Main
    Clear-Host
}
catch {
    Write-Error "Error from Show-Main: $_"
}