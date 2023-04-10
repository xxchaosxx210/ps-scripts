# loops through each file in the current directory . and lists the names of the files

Get-ChildItem -Path . -File | ForEach-Object { $_.Name }