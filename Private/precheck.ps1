#requires -version 6.2

function precheck {
    <#
    .SYNOPSIS
    PreCheck
    .DESCRIPTION
    This function is used as a precheck step by all the functions to test all the required authentication and properties.
    .EXAMPLE
    precheck
    Run the test
    .NOTES
    NAME: precheck
    #>

    # Check if API Token is null or empty
    if ([string]::IsNullOrEmpty($script:apiToken)) {
        $tokenInput = Read-Host -Prompt "Please enter your Stairwell API Token"
        if ($tokenInput -match "\w{52}") {
            $script:apiToken = $tokenInput
        } else {
            Write-Warning "Invalid format for API Token: $($tokenInput)"
        }
        
    }


    # Check if Environment ID is null or empty
    if ([string]::IsNullOrEmpty($script:environmentId) -and $null -ne $SWenvironmentId) {
        $envInput = Read-Host -Prompt "Please enter your Stairwell Environment ID"
        if ($envInput -match "\w{6}\-\w{6}\-\w{6}\-\w{8}") {
            $script:environmentId = $envInput
        } else {
            Write-Warning "Invalid format for Environment ID: $($envInput)"
        }

    }

    # Common values to be used by modules
    $script:baseUri = "https://app.stairwell.com/v1/"
    $script:headers = @{
        'Accept' = 'application/json'
        'Content-Type' = 'application/json'
        'Authorization' = $script:apiToken
        'x-api-source' = 'Stairwell PowerShell Module'
    }

}