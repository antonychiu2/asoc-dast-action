Write-Host "Starting ASoC script"

#DEBUG
Write-Warning "Print environment variables:"
Write-Host "github.sha: " $env:GITHUB_SHA
dir env:

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

#VARIABLES
$global:BearerToken = ""

function ASoC-Login {


  $jsonBodyInPSObject = @{
    KeyId         = $env:INPUT_asoc_key
    KeySecret     = $env:INPUT_asoc_secret
  }

  $params = @{
      Uri         = "$env:INPUT_baseurl/Account/ApiKeyLogin"
      Method      = 'POST'
      Body        = $jsonBodyInPSObject | ConvertTo-Json
      Headers = @{
          'Content-Type' = 'application/json'
        }
      }
  $Members = Invoke-RestMethod @params
  #Write-Host "Auth successful - Token received: $Members.token"
  $global:BearerToken = $Members.token
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

function Run-ASoC-DynamicAnalyzerNoAuth {


  $jsonBody = "
  {
    `"ScanType`": `"$env:INPUT_scan_type`",
    `"IncludeVerifiedDomains`": true,
    `"StartingUrl`": `"$env:INPUT_starting_URL`",
    `"TestOptimizationLevel`": `"NoOptimization`",
    `"UseAutomaticTimeout`": true,
    `"MaxRequestsIn`": 10,
    `"MaxRequestsTimeFrame`": 1000,
    `"OnlyFullResults`": true,
    `"FullyAutomatic`": true,
    `"ScanName`": `"$env:GITHUB_REPOSITORY $env:GITHUB_SHA`",
    `"EnableMailNotification`": true,
    `"Locale`": `"en-US`",
    `"AppId`": `"$env:INPUT_application_id`",
    `"Execute`": true,
    `"Personal`": false,
  }
  "
  write-host $jsonBody
  
  $params = @{
      Uri         = "$env:INPUT_baseurl/Scans/DynamicAnalyzer"
      Method      = 'POST'
      Body        = $jsonBody
      Headers = @{
          'Content-Type' = 'application/json'
          Authorization = "Bearer $global:BearerToken"
        }
      }
  $Members = Invoke-RestMethod @params
  write-host $Members
}

#MAIN
ASoC-Login

if($global:BearerToken -ne ""){
  Write-Host "Login successful"
}else{
  Write-Host "Login failed, bearer token is empty... exiting"
  exit 1
}

Run-ASoC-DynamicAnalyzerNoAuth