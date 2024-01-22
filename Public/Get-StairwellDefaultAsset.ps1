#requires -version 6.2

function Get-StairwellDefaultAsset {
    [alias('SwDefaultAsset')]
    <#
    .SYNOPSIS
    Obtains the default asset id for a given Stairwell environment
    .DESCRIPTION
    This function fetches the default asset id for your Stairwell environment.
    This comes in handy when uploading files and you do not want or have another active asset to attribute it to.
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    .EXAMPLE
    Get-StairwellDefaultAsset -EnvironmentId "<ENVIRONMENT-ID>"
    
    ABC123-ZYX654-LMN789-DEFG6543

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$NewEnvironmentId,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the Api Token for your Stairwell environment.")]
        [ValidatePattern("\w{52}")]
        [string]$NewApiToken
    )

    begin {
        # precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        if($Null -ne $NewEnvironmentId) {
            Write-Verbose "Getting Default AssetId for supplied Environment: $($NewEnvironmentId)"
            $SWEnvironmentId = $NewEnvironmentId
        } else {
            if($Null -ne $script:EnvironmentId) {
                Write-Verbose "Getting Default AssetId for Environment from config: $($script:EnvironmentId)"
                $SWEnvironmentId = $script:EnvironmentId
            } else {
                $envInput = Read-Host -Prompt "Enter your Stairwell Environment ID"
                if ($envInput -match "\w{6}\-\w{6}\-\w{6}\-\w{8}") {
                    $script:environmentId = $envInput
                    $SWEnvironmentId = $envInput
                } else {
                    Write-Warning "Invalid format for Environment ID: $($envInput)"
                }
            }
        }

        if($Null -ne $NewApiToken) {
            Write-Verbose "Using supplied Api Token"
            $SWApiToken = $NewApiToken
        } else {
            if($Null -ne $script:ApiToken) {
                Write-Verbose "Using ApiToken from config"
                $SWApiToken = $script:ApiToken
            } else {
                $tokenInput = Read-Host -Prompt "Enter your Stairwell Api Token"
                if ($tokenInput -match "\w{52}") {
                    $script:ApiToken = $tokenInput
                    $SWApiToken = $tokenInput
                } else {
                    Write-Warning "Invalid format for API Token: $($tokenInput)"
                }
            }
        }
        

        Write-Verbose "Using ApiKey: $($SWapiToken)"
        Write-Verbose "Using EnvironmentId: $($SWEnvironmentId)"
        
        $Url = $script:baseUri + 'environments/' + $SWEnvironmentId + '/assets'
        Write-Verbose "Using Url to get default asset: $($Url)"
        
        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = @{'Authorization' = $SWapiToken}
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }
        
        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                foreach ($asset in $Content.assets) {
                    if ($asset.label -eq "__DefaultAsset__") {
                        $script:DefaultAsset = ($asset.name).substring(7)
                        Write-Verbose "Default asset ID: $($script:DefaultAsset)"
                        return $script:DefaultAsset
                    }
                }
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }

}