function Set-StairwellConfig {
    [alias('SSwC')]
    <#
    .SYNOPSIS
    Enable Stairwell module
    .DESCRIPTION
    This function enables the Stairwell module by setting up the required credentials
    .PARAMETER ApiToken
    Enter the Api Token from the Stairwell platform. See: https://docs.stairwell.com/docs/how-to-create-an-authentication-token
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    .EXAMPLE
    Set-StairwellConfig -ApiToken "<API-TOKEN>" -EnvironmentId "<ENVIRONMENT-ID>"
    This example will enable Stairwell for the provided environment
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
        HelpMessage="Enter the ApiToken from your Stairwell environment.")]
        [ValidatePattern("\w{52}")]
        [string]$ApiToken,

        [Parameter(Mandatory,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId
    )

    begin {
    
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Setting the environment config for the Stairwell module. This will overwrite any previous config."
        
        if (($Null -ne $ApiToken) -and ($Null -ne $EnvironmentId)) {
            Write-Verbose "New Stairwell ApiToken and EnvironmentId submitted."
            $script:ApiToken = $ApiToken
            $script:EnvironmentId = $EnvironmentId           
        } else {
            Write-Verbose "No config variables supplied, prompting user for values."
            
            precheck
        }

        # Try to grab the the default asset id here, nice to have if we need to upload files
        if($Null -eq $script:DefaultAsset) {
            $script:DefaultAsset = Get-StairwellDefaultAsset -NewEnvironmentId $script:EnvironmentId -NewApiToken $script:ApiToken
        }
        Write-Verbose "The Default AssetId is set to: $($script:DefaultAsset)"

    }
}
