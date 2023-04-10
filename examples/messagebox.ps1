# This code defines a PowerShell function called "Show-MessageBox" 
# that displays a message box with customizable text, title, buttons, and icon. 
# The function uses the .NET Framework's System.Windows.Forms.MessageBox class 
# to create the message box. 

# The function takes four parameters: "Text" (mandatory), "Title" (optional, defaults to "Message"), 
# "Buttons" (optional, defaults to OKCancel), and "Icon" (optional, defaults to Information). 

# When the function is called, it displays the message box and returns the user's response 
# (e.g. OK, Cancel, Yes, No).

# Load the .NET Forms class first
Add-Type -AssemblyName System.Windows.Forms

function Show-MessageBox {
    Param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$Title = "Message",
        [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
    )
    return [System.Windows.Forms.MessageBox]::Show($Text, $Title, $Buttons, $Icon)
}

$result = Show-MessageBox -Text "Would you like to Continue?" -Title "Continue?" -Buttons OKCancel -Icon Question

if ($result -eq "OK") {
    Write-Output "You clicked OK"
}
else {
    Write-Output "You clicked Cancel"
}