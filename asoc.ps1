Write-Host "Starting ASoC script"

#DEBUG
Write-Warning "Print environment variables:"
Write-Host "github.sha: " $env:GITHUB_SHA
dir env:

#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

#VARIABLES
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

#FUNCTIONS
function Login-ASoC {

  $jsonBodyInPSObject = @{
    KeyId         = $env:INPUT_asoc_key
    KeySecret     = $env:INPUT_asoc_secret
  }

  $params = @{
      Uri         = "$global:BaseAPIUrl/Account/ApiKeyLogin"
      Method      = 'POST'
      Body        = $jsonBodyInPSObject | ConvertTo-Json
      Headers = @{
          'Content-Type' = 'application/json'
        }
      }
  $Members = Invoke-RestMethod @params
  #Write-Host "Auth successful - Token received: $Members.token"
  $global:BearerToken = $Members.token

  if($global:BearerToken -ne ""){
    Write-Host "Login successful"
  }else{
    Write-Host "Login failed, bearer token is empty... exiting"
    exit 1
  }
  
}

function Set-AppScanPresence{

  if($env:INPUT_network -eq 'private'){
    
    $global:jsonBodyInPSObject.Add("PresenceId",$env:INPUT_presence_id)
<# 
    $global:jsonBodyInPSObject =+ @{
      PresenceId = $env:INPUT_presence_id
    } #> 
  }
}

function Lookup-ASoC-Application ($ApplicationName) {

  $params = @{
      Uri         = "$env:INPUT_baseurl/Apps/GetAsPage"
      Method      = 'GET'
      Headers = @{
          'Content-Type' = 'application/json'
          Authorization = "Bearer $global:BearerToken"
        }
      }
  $Members = Invoke-RestMethod @params
  Write-Host @Members
  $Members.Items.Contains($ApplicationName)
}


function Run-ASoC-FileUpload($filepath){

  #ls -l
  $uploadedFile = [IO.File]::ReadAllBytes($filepath)
  $params = @{
    Uri         = "$global:BaseAPIUrl/FileUpload"
    Method      = 'Post'
    Headers = @{
      'Content-Type' = 'multipart/form-data'
      Authorization = "Bearer $global:BearerToken"
    }
     Form = @{
    'fileToUpload' = Get-Item -Path $filepath
   }
  }
  $upload = Invoke-RestMethod @params
  $upload_File_ID = $upload.FileId
  write-host "File Uploaded - File ID: $upload_File_ID"

  return $upload_File_ID
}
function Run-ASoC-DynamicAnalyzerNoAuth {
  Write-Host "Proceeding with no authentications..." -ForegroundColor Green

  return Run-ASoC-DynamicAnalyzerAPI($global:jsonBodyInPSObject | ConvertTo-Json)
}
function Run-ASoC-DynamicAnalyzerUserPass{
  Write-Host "Proceeding with username and password login..." -ForegroundColor Green

  $global:jsonBodyInPSObject.Add("LoginUser",$env:INPUT_login_user)
  $global:jsonBodyInPSObject.Add("LoginPassword",$env:INPUT_login_password)

  return Run-ASoC-DynamicAnalyzerAPI($jsonBodyInPSObject | ConvertTo-Json)
}

function Run-ASoC-DynamicAnalyzerRecordedLogin{

  Write-Host "Proceeding with recorded Login..." -ForegroundColor Green
  #Upload Recorded Login File
  $FileID = Run-ASoC-FileUpload($env:INPUT_login_sequence_file)
  $global:jsonBodyInPSObject.Add("LoginSequenceFileId",$FileID)
  return Run-ASoC-DynamicAnalyzerAPI($jsonBodyInPSObject | ConvertTo-Json)
}


function Run-ASoC-DynamicAnalyzerWithFile{

  $FileID = Run-ASoC-FileUpload($env:INPUT_scan_file)
  $global:jsonBodyInPSObject.Add("ScanFileId",$FileID)

  return Run-ASoC-DynamicAnalyzerWithFileAPI($jsonBodyInPSObject | ConvertTo-Json)
}


function Run-ASoC-DynamicAnalyzerAPI($json){

  write-host $json
  $params = @{
    Uri         = "$global:BaseAPIUrl/Scans/DynamicAnalyzer"
    Method      = 'POST'
    Body        = $json
    Headers = @{
        'Content-Type' = 'application/json'
        Authorization = "Bearer $global:BearerToken"
      }
    }

  #DEBUG
  Write-Host $params
  
  $Members = Invoke-RestMethod @params
  return $Members.Id
}

function Run-ASoC-DynamicAnalyzerWithFileAPI($json){

  write-host $json
  $params = @{
    Uri         = "$global:BaseAPIUrl/Scans/DynamicAnalyzerWithFile"
    Method      = 'POST'
    Body        = $json
    Headers = @{
        'Content-Type' = 'application/json'
        Authorization = "Bearer $global:BearerToken"
      }
    }
  #DEBUG
  Write-Host $params

  $Members = Invoke-RestMethod @params
  return $Members.Id
}

function Run-ASoC-DAST{

  #FIRST check if dynamic_scan_type is 'upload' or 'dast'
  if($env:INPUT_dynamic_scan_type -eq 'upload'){
    return Run-ASoC-DynamicAnalyzerWithFile
  
  #If dynamic_scan_type is not 'upload' then it is a regular 'dast' scan. We proceed to check if it's a userpass login or recorded login
  }elseif($env:INPUT_login_method -eq 'userpass'){
    return Run-ASoC-DynamicAnalyzerUserPass

  }elseif($env:INPUT_login_method -eq 'recorded'){
    return Run-ASoC-DynamicAnalyzerRecordedLogin

  }else{
    return Run-ASoC-DynamicAnalyzerNoAuth
  }
}

function Run-ASoC-ScanCompletionChecker($scanID){
  $params = @{
    Uri         = "$global:BaseAPIUrl/Scans/$scanID/Executions"
    Method      = 'Get'
    Headers = @{
      'Content-Type' = 'application/json'
      Authorization = "Bearer $global:BearerToken"
    }
  }
  #DEBUG
  Write-Host $params

  $counterTimerInSeconds = 0
  Write-Host "Waiting for Scan Completion..." -NoNewLine
  $waitIntervalInSeconds = 30

  while(($scan_status -ne "Ready") -and ($counterTimerInSeconds -lt $env:INPUT_wait_for_analysis_timeout_minutes*60)){
    $output = Invoke-RestMethod @params
    $scan_status = $output.Status
    Start-Sleep -Seconds $waitIntervalInSeconds
    $counterTimerInSeconds = $counterTimerInSeconds + $waitIntervalInSeconds
    Write-Host "." -NoNewline
  }
  Write-Host ""
}
function Run-ASoC-GenerateReport ($scanID) {

  $params = @{
    Uri         = "$global:BaseAPIUrl/Reports/Security/Scan/$scanID"
    Method      = 'Post'
    Headers = @{
      'Content-Type' = 'application/json'
      Authorization = "Bearer $global:BearerToken"
    }
  }
  $body = @{
    'Configuration' = @{
      'Summary' = "true"
      'Details' = "true"
      'Discussion' = "true"
      'Overview' = "true"
      'TableOfContent' = "true"
      'Advisories' = "true"
      'FixRecommendation' = "true"
      'History' = "true"
      'Coverage' = "true"
      'MinimizeDetails' = "true"
      'Articles' = "true"
      'ReportFileType' = "HTML"
      'Title' = "false"
      'Locale' = "en-US"
      'Notes' = "Github SHA: $env:GITHUB_SHA"
    }
  }
  #DEBUG
  Write-Host $params
  write-host $body

  $output_runreport = Invoke-RestMethod @params -Body ($body|ConvertTo-JSON)
  $report_ID = $output_runreport.Id
  return $report_ID
}

function Run-ASoC-ReportCompletionChecker($reportID){

  #Wait for report
  $params = @{
    Uri         = "$global:BaseAPIUrl/Reports/$reportID"
    Method      = 'Get'
    Headers = @{
      'Content-Type' = 'application/json'
      Authorization = "Bearer $global:BearerToken"
    }
  }
  #DEBUG
  Write-Host $params

  $report_status ="Not Ready"
  while($report_status -ne "Ready"){
    $output = Invoke-RestMethod @params
    $report_status = $output.Status
    Start-Sleep -Seconds 5
    Write-Host "Generating Report... Progress: " $output.Progress "%"
  } 
}

function Run-ASoC-DownloadReport($eportID){

  #Download Report
  $params = @{
    Uri         = "$global:BaseAPIUrl/Reports/Download/$eportID"
    Method      = 'Get'
    Headers = @{
      'Accept' = 'text/html'
      Authorization = "Bearer $global:BearerToken"
    }
  }
  #DEBUG
  Write-Host $params
  
  $output_runreport = Invoke-RestMethod @params
  Out-File -InputObject $output_runreport -FilePath .\AppScan_Security_Report.html
  
}

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
ls -l