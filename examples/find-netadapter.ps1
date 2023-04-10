# Reads input from Powershell and finds the Network Adapter name and displays the MAC Address if found

$netName = Read-Host "WiFi Name: "
$wifiObject = Get-NetAdapter | Where-Object { $_.Name -eq $netName }
# $null needs to start, very odd
if ($null -eq $wifiObject) {
    Write-Host "No Adapter found"
}
else {
    # Write-Host "IPAddress: " + $wifiObject.MacAddress
    Write-Host "Mac Address: " + $wifiObject.MacAddress
}