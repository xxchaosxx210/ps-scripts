# generates a set of random numbers for the Euro-Millions. 
# It uses the function Get-Random-Numbers to generate a specified number of random integers 
# within a given range, without duplicates. 
# The main balls are generated between 1 and 50, and 5 numbers are generated. 
# The lucky stars are generated between 1 and 12, and 2 numbers are generated. 
# The output displays the main balls and lucky stars separated by commas.

function Get-Random-Numbers {
    Param(
        [int]$Minimum,
        [int]$Maximum,
        [int]$Count
    )
    # create an array to store the random numbers
    $numbers = @()
    # keep looping until the array is maxed
    while ($numbers.Count -lt $Count) {
        # get a seed for the randomizer
        $seedNumber = (Get-Date).Millisecond
        # generate a random number
        $randomNumber = Get-Random -Minimum $Minimum -Maximum $Maximum -SetSeed $seedNumber
        # make sure we dont have a number replicant
        if ($randomNumber -notin $numbers) {
            $numbers += $randomNumber
        }
    }
    return $numbers
}


$main_balls = Get-Random-Numbers -Minimum 1 -Maximum 50 -Count 5 | Sort-Object
Write-Host "Numbers: " -NoNewline
Write-Host $main_balls -Separator ","
Write-Host "`nLucky Stars: " -NoNewline
$lucky_stars = Get-Random-Numbers -Minimum 1 -Maximum 12 -Count 2 | Sort-Object
Write-Host $lucky_stars -Separator ","
Write-Output ""

