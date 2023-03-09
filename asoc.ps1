Write-Host "Starting ASoC script"

#DEBUG
Write-Warning "Print environment variables:"
Write-Host "env:application_id: " $env:application_id
Write-Host "env:baseurl: " $env:baseurl

# ASoC - Login to ASoC with API Key and Secret
$jsonBody = "
{
`"KeyId`": `"$env:ASOC_KEY`",
`"KeySecret`": `"$env:ASOC_SECRET`"
}
"

$params = @{
    Uri         = "$baseURL/Account/ApiKeyLogin"
    Method      = 'POST'
    Body        = $jsonBody
    Headers = @{
        'Content-Type' = 'application/json'
      }
    }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$Members = Invoke-RestMethod @params
Write-Host "Auth successful - Token received: $Members.token"
$bearer_token = $Members.token
$ProgressPreference = 'SilentlyContinue'

