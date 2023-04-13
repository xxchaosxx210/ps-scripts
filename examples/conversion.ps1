# this example code shows how to convert variables between types

$Str = "1"
Write-Host "Str is of type: $($Str.GetType())"
if ($Str -as [int]) {
    [int]$NumValue = [convert]::ToInt32($Str)
    Write-Host "NumValue is now type: $($NumValue.GetType())"
}