$alphabet = @(
  '0', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
  'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q',
  'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
)

$timeoutInSeconds = 60
$outputFile = './output.txt'
$gamesUrl = 'http://nesguide.com/games'

Function FindBoxArt {
  [CmdletBinding()]
  Param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string] $Url
  )

  Write-Host "Uri: $Url"

  Start-Sleep -Seconds 2
  $response = Invoke-WebRequest -Uri $Url -TimeoutSec $timeoutInSeconds
  $response.Images `
    | Where-Object { $_.src -match 'images/art/' } `
    | ForEach-Object { Add-Content -Path $outputFile -Value "http:$($_.src)" }
}

Function FindPagesForLetter {
  [CmdletBinding()]
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string] $Letter
  )

  Write-Host "Gathering links to box art for the games starting with the letter '$Letter'"

  $url = "$($gamesUrl)/$($Letter)/"

  FindBoxArt $url

  $response = Invoke-WebRequest -Uri $url -TimeoutSec $timeoutInSeconds
  $response.Links `
    | Where-Object { $_.outerHtml -match "//nesguide\.com/games/$($Letter)/\d+/`">\d+</a>" } `
    | Sort-Object -Property 'href' `
    | Select-Object -Property 'href' -Unique `
    | ForEach-Object { FindBoxArt "http:$($_.href)" }
}

Function Main {
  $alphabet | ForEach-Object { FindPagesForLetter $_ }
}

Main