# an example of how to declare and use a scriptblock. Similar to a lambda in python, or
# an anonymouse function in JS

$myFunction = {
    Param([int]$x, [int]$y)
    return $x + $y
}

$result = &$myFunction 2 2

Write-Host "The answer to 2 + 2 = $result"