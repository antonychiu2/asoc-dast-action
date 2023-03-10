$env:INPUT_baseurl = "https://cloud.appscan.com/api/V2"
$env:INPUT_asoc_key = "082c4037-2bd5-380a-09e1-a1754a5eaab0"
$env:INPUT_asoc_secret = "fMM4inw4zR2ip3ovtZHyVLoRenA2sd9Fq9MRNhjTx5s="
$env:INPUT_application_id = 'acd3ef50-6276-461d-8514-abc6e7113577'
$env:INPUT_scan_name = 'sample scan name'
$env:GITHUB_SHA = "sha265-random-sha-value"
$env:GITHUB_REPOSITORY = "antonychiu2/github-demo"
$env:INPUT_scan_type = 'staging' #production, staging

$env:INPUT_login_method = 'none' #none, userpass, record
$env:INPUT_starting_URL = "https://demo.testfire.net?mode=demo"

#IF LOGIN = NONE


$env:INPUT_application_name = 'Github Action Demo Application'

./asoc.ps1