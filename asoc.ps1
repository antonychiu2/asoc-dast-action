Write-Host "Starting ASoC script"
$env:ASOC_KEY = "abcd"
$env:ASOC_SECRET = "efgh"


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

