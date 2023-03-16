#During Job Cancellation, we want to also try to stop the scan if it was already initiated

#DEBUG
dir env:
$DebugPreference = "Continue"

#INITIALIZE VARIABLES
$scanidFileName = ".\scanid.txt"
$global:BaseAPIUrl = $env:INPUT_BASEURL + "/api/V2"

#LOAD ALL ASOC FUNCTIONS FROM LIBRARY FILE asoc.ps1
. "$env:GITHUB_ACTION_PATH/asoc.ps1"


$global:scanId = Get-Content $scanidFileName | Select -First 1
Write-Host "ScanID: $global:scanId"

Login-ASoC

Delete-LatestRunningScanExecution($global:scanId)