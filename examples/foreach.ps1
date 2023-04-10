# in this example the foreach loop will be used
# PSItem contains the return value from the pipeline

Write-Host "Showing all Process Names: "

Get-Process | ForEach-Object { $PSItem.Name }