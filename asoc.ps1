Write-Host "Starting ASoC script"

#DEBUG
Write-Warning "Print environment variables:"
Write-Host "inputs:application_id: " $env:INPUT_APPLICATION_ID
Write-Host "inputs:baseurl: " $env:INPUT_baseurl
Write-Host $input:INPUT_baseurl
Write-Host ${INPUT_baseurl}
Write-Host ${$input:INPUT_baseurl}
Write-Host ${$input:BASEURL}
Write-Host $input:baseurl
Write-Host ${inputs.application_id}
Write-Host ${inputs.baseurl}


Write-Host ${github.action_path}
Write-Host "github.sha: " $env:GITHUB_SHA
dir env:

# ASoC - Login to ASoC with API Key and Secret
$jsonBody = "
{
`"KeyId`": `"$env:INPUT_asoc_key`",
`"KeySecret`": `"$env:INPUT_asoc_secret`"
}
"

$params = @{
    Uri         = "$env:INPUT_baseurl/Account/ApiKeyLogin"
    Method      = 'POST'
    Body        = $jsonBody
    Headers = @{
        'Content-Type' = 'application/json'
      }
    }

Write-Host @params

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$Members = Invoke-RestMethod @params
Write-Host "Auth successful - Token received: $Members.token"
$bearer_token = $Members.token
Write-Host $bearer_token
$ProgressPreference = 'SilentlyContinue'

