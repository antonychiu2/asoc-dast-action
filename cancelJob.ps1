#During Job Cancellation, we want to also try to stop the scan if it was already initiated



#LOAD ALL ASOC FUNCTIONS FROM LIBRARY FILE asoc.ps1
. "$env:GITHUB_ACTION_PATH/asoc.ps1"
$scanidFileName = ".\scanid.txt"

dir env:
$global:scanId = Get-Content $scanidFileName | Select -First 1
Write-Host "ScanID: $global:scanId"

Delete-LatestRunningScanExecution($global:scanId)