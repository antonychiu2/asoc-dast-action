$env:INPUT_baseurl = "https://cloud.appscan.com" 
$env:INPUT_asoc_key = "082c4037-2bd5-380a-09e1-a1754a5eaab0"
$env:INPUT_asoc_secret = "fMM4inw4zR2ip3ovtZHyVLoRenA2sd9Fq9MRNhjTx5s="
$env:INPUT_application_id = 'acd3ef50-6276-461d-8514-abc6e7113577'
$env:INPUT_scan_name = 'sample scan name'
$env:GITHUB_SHA = "sha265-random-sha-value"
$env:GITHUB_REPOSITORY = "antonychiu2/github-demo"
$env:INPUT_scan_type = 'staging' #production, staging
$env:INPUT_starting_URL = "https://demo.testfire.net?mode=demo"
$env:INPUT_optimization = 'NoOptimization'


#IF LOGIN = NONE

#DAST or SCAN File
$env:INPUT_dynamic_scan_type = "dast"
$env:INPUT_scan_file = "/Users/antonychiu/Box/HCL/Github Actions/asoc-dast-action/asoc-dast-action/altoro.scant"

#NETWORK
$env:INPUT_network = 'public'
$env:INPUT_presence_id = 'f185efda-67bf-ed11-ba76-14cb65723612'

#For 'dast' type scan, user will choose the type of login method

$env:INPUT_login_method = 'recorded' #options: none, username, recorded

#IF LOGIN_METHOD = USERPASS
$env:INPUT_login_user = 'jsmith'
$env:INPUT_login_password = 'demo1234'
$env:INPUT_login_extra_field = 'test123'

#IF LOGIN METHOD = RECORD
$env:INPUT_login_sequence_file = '/Users/antonychiu/Box/HCL/Github Actions/asoc-dast-action/asoc-dast-action/login.dast.config'

#MISC
$env:INPUT_email_notification = 'true'
$env:INPUT_personal_scan = 'false'
$env:INPUT_intervention = 'true'
$env:INPUT_wait_for_analysis = 'true'
$env:INPUT_wait_for_analysis_timeout_minutes = '360'
$env:INPUT_fail_for_noncompliance = 'false'

./asoc.ps1