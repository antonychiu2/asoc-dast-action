#During Job Cancellation, we want to also try to stop the scan if it was already initiated



#LOAD ALL ASOC FUNCTIONS FROM LIBRARY FILE asoc.ps1
. "$env:GITHUB_ACTION_PATH/asoc.ps1"

dir env:
write-host "$env:scanId"