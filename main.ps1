
Write-Host "Starting ASoC script"

#DEBUG
Write-Warning "Print environment variables:"
Write-Host "github.sha: " $env:GITHUB_SHA
dir env:
ls -l

#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

#INITIALIZING VARIABLES
$global:BearerToken = ""
$global:scan_name = "$env:GITHUB_REPOSITORY $env:GITHUB_SHA"
$global:jsonBodyInPSObject = ""
$global:scanId
$global:BaseAPIUrl = ""
$global:BaseAPIUrl = $env:INPUT_baseurl + "/api/V2"

#INITIALIZE
#Construct base JSON Body for DAST Scan for API DynamicAnalyzer and DynamicAnalyzerWithFiles
$global:jsonBodyInPSObject = @{
  ScanType = $env:INPUT_scan_type
  IncludeVerifiedDomains = $true
  StartingUrl = $env:INPUT_starting_URL
  TestOptimizationLevel = $env:INPUT_optimization
  UseAutomaticTimeout = $true
  MaxRequestsIn = 10
  MaxRequestsTimeFrame = 1000
  OnlyFullResults = $true
  FullyAutomatic = $true
  ScanName = $global:scan_name
  EnableMailNotification = $env:INPUT_email_notification
  Locale = 'en-US'
  AppId = $env:INPUT_application_id
  Execute = $true
  Personal = $env:INPUT_personal_scan
}

#LOAD ALL ASOC FUNCTIONS FROM LIBRARY FILE asoc.ps1
. "$env:GITHUB_ACTION_PATH/asoc.ps1"
#MAIN
Login-ASoC

#CHECK NETWORK, if private, then set presence ID
Set-AppScanPresence

#Run DAST Scan
$global:scanId = Run-ASoC-DAST

#Display ASoC Scan URL
$scanOverviewPage = $env:INPUT_baseurl + "/main/myapps/" + $env:INPUT_application_id + "/scans/" + $global:scanId
Write-Host "Scan is initiated and can be viewed in ASoC Scan Dashboard:" 
Write-Host $scanOverviewPage -ForegroundColor Green

#If wait_for_analysis is set to true, we proceed to wait before generating report
if(-not($wait_for_analysis -eq $true)){

  #Check for report completion
  Run-ASoC-ScanCompletionChecker ($global:scanId)

  #Send for report generation
  $reportID = Run-ASoC-GenerateReport ($global:scanId)
  
  #Check for report generation completion
  Run-ASoC-ReportCompletionChecker ($reportID)

  #Download report from ASoC
  Run-ASoC-DownloadReport($reportID){

  }
}

#Fail the build if fail_for_noncompliance is true and scan results in exceeding the threshold set in fail_threshold
if($env:INPUT_fail_for_noncompliance -eq $true){

  $jsonData = Run-ASoC-GetIssueCount $global:scanId 'All'
  $jsonData
  
  $failBuild = $false
  $failBuild = FailBuild-ByNonCompliance($jsonData)
  if($failBuild -eq $true){
      Write-Error "Job failed - Scan has determined non-compliance with the application policy set in ASoC."
      exit 1
  }
  else{
      Write-Host "Job Successful - Scan has determined compliance with policy current application policies set in ASoC." -ForegroundColor Green
  }
}

#Fail the build if fail_by_severity is true and scan results in non-compliance
if($env:INPUT_fail_by_severity -eq $true){
  $jsonData = Run-ASoC-GetIssueCount $global:scanId 'None'
  $jsonData
  $failBuild = $false
  $failBuild = FailBuild-BySeverity $jsonData $env:INPUT_failure_threshold
  Write-Host $failBuild 

  if($failBuild -eq $true){
      Write-Error "Job failed - Scan has found security issues equal to or above the threshold set: $env:INPUT_failure_threshold"
      exit 1
  }
  else{
      Write-Host "Job Successful - Scan has found no issues equal to or above the threshold set: $env:INPUT_failure_threshold." -ForegroundColor Green
  }
}

