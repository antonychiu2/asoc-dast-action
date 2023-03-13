function Run-ASoC-GetIssueCount($scanID){
    
    #/api/v2/Issues/CountBySeverity/{scope}/{scopeId}
    $params = @{
        Uri         = "$global:BaseAPIUrl/Issues/CountBySeverity/ScanExecution/$scanID?applyPolicies=All"
        Method      = 'GET'
        Headers = @{
        'Content-Type' = 'application/json'
        Authorization = "Bearer $global:BearerToken"
        }
    }
    #DEBUG
    Write-Host $params

    $jsonOutput = Invoke-RestMethod @params
    return $jsonOutput

    #DEBUG
    write-host $jsonOutput
}

function Set-BuildFail($resultJson){



}