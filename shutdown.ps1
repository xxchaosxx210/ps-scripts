# Shows a shutdown menu for shutting down, logging out ans rebooting

# some of the example code shows how to use CIM (Common Information Model) and Invoke a CIM Method
# Another is showing how to read a key input from the keyboard similar to C function getch which
# was incredibly handy and wasn't part of the C standard library

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
displays a menu for selecting a Windows operating system from a list of Win32OSInstances. 
#>
function Show-Windows-Selection-Menu {
    Param(
        [ciminstance[]]$Win32OSInstances
    )
    Write-Host "Please select your Windows OS.`n"
    [int]$index = 0
    $Win32OSInstances | foreach-object -Process {
        Write-Host "$($index + 1). $($_.Caption)"
        $index++
    }
    Write-Host "Q. Quit Script"
    Write-Host "Selection: " -NoNewline
}

<#
.SYNOPSIS
This function displays a menu of operating system shutdown options, 
including shutdown, reboot, logout, and quit
#>
function Show-OS-Shutdown-Options {
    Write-Host "------------"
    Write-Host "Normal"
    Write-Host "------------"
    Write-Host "1. Shutdown"
    Write-Host "2. Reboot"
    Write-Host "3. Logout"
    Write-Host "------------"
    Write-Host "Force"
    Write-Host "------------"
    Write-Host "4. Shutdown"
    Write-Host "5. Reboot"
    Write-Host "6. Logout"
    Write-Host "------------"
    Write-Host "Q. Quit"
    Write-Host "------------"
    Write-Host "Selection: " -NoNewline
}


function Get-Selection {
    <#
    .DESCRIPTION
    Takes in an array of PSObjects and an optional escape key character. 
    The function then enters into an infinite loop and waits for user input. 
    If the user presses the key that matches the $EscapeKey, the function returns -1. 
    If the user presses a digit key, the function checks if the value is within the range 
    of the PSObjects array length and returns the index of the selected object 
    (minus one to account for zero-based indexing). 
    This function is designed to allow the user to select an object from an array 
    by typing in the corresponding number or escape to cancel the selection.
    #>
    Param(
        [PSObject[]]$PSObjects,
        [char]$EscapeKey = 'q'
    )
    while ($true) {
        $key = Get-Key-Press
        if ([Char]::IsLetter($key) -and $key -eq $EscapeKey) {
            return -1
        }
        elseif ([Char]::IsDigit($key)) {
            $keyValue = [convert]::ToInt32("$key")
            if ($keyValue -gt 0 -and $keyValue -le $PSObjects.Length) {
                return $($keyValue - 1)
            }
        }
    }
}
    
function Show-Main {
    # Get availible Windows OS versions on the system
    $Win32OSystems = Get-CimInstance -Query "SELECT * FROM Win32_OperatingSystem"
    # $Win32OSystems = Get-CimInstance -ClassName Win32_OperatingSystem
    # show availible windows for selection
    Show-Windows-Selection-Menu -Win32OSInstances $Win32OSystems
    # read from the keyboard and get the selection
    $SelectedIndex = Get-Selection -PSObjects $Win32OSystems
    # if selected key was the escape key then exit otherwise proceed getting the windows instance
    if ($SelectedIndex -eq -1) {
        return
    }
    $SelectedWin32OS = $Win32OSystems[$SelectedIndex]
    $ShutdownFlags = @($SHUTDOWN_FLAG, $REBOOT_FLAG, $LOGOFF_FLAG, $FORCE_SHUTDOWN_FLAG, $FORCE_REBOOT_FLAG, $FORCE_LOGOFF_FLAG)
    Write-Host "`n"
    Show-OS-Shutdown-Options
    $SelectedIndex = Get-Selection -PSObjects $ShutdownFlags
    if ($SelectedIndex -eq -1) {
        return
    }
    try {
        $ShutdownArgs = @{Flags = $ShutdownFlags[$SelectedIndex] }
        Invoke-CimMethod -InputObject $SelectedWin32OS -MethodName Win32Shutdown -Arguments $ShutdownArgs
        Write-Host "Now exiting..."
    }
    catch {
        Write-Host "Error: $_"
    }
}

$SHUTDOWN_FLAG = 1
$REBOOT_FLAG = 2
$LOGOFF_FLAG = 0
$FORCE_SHUTDOWN_FLAG = 5
$FORCE_REBOOT_FLAG = 6
$FORCE_LOGOFF_FLAG = 4

Show-Main