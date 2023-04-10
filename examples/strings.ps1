# examples of using and formatting strings in PowerShell

$text = "Paul"
# Using a placeholder
Write-Output "text variable contains ${text}"
# Displaying text without using escape sequaences and placeholders. Use the single quotes
Write-Output 'Text variable contains ${text}'
# Using the Newline within a string literal
Write-Host "This is an example" -NoNewline
Write-Host " of multiple sentences of text being on the same line" -NoNewline
Write-Host "`nThis should now be on a new line`n" -NoNewline