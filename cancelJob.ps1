#During Job Cancellation, we want to also try to stop the scan if it was already initiated

#DEBUG
#dir env:
#$DebugPreference = "Continue"
$DebugPreference = "SilentlyContinue"

#INITIALIZE VARIABLES
$scanidFileName = ".\scanid.txt"
$ephemeralPresenceIdFileName =".\ephemeralPresenceId.txt"

$global:BaseAPIUrl = $env:INPUT_BASEURL + "/api/V2"

#LOAD ALL ASOC FUNCTIONS FROM LIBRARY FILE asoc.ps1
. "$env:GITHUB_ACTION_PATH/asoc.ps1"


$global:scanId = Get-Content $scanidFileName | Select -First 1
Write-Host "ScanID: $global:scanId"

Login-ASoC

Delete-LatestRunningScanExecution($global:scanId)

# kill the ephemeral presence if one was set
if($env:INPUT_EPHEMERAL_PRESENCE -eq $true){
    
    $global:ephemeralPresenceId = Get-Content $ephemeralPresenceIdFileName | Select -First 1
    Write-Host "Ephemeral Presence ID extracted from file: $global:ephemeralPresenceId"
    
    Write-Host "Deleting ephemeral presence with ID: $global:ephemeralPresenceId"
    Run-ASoC-DeletePresence($global:ephemeralPresenceId)
}