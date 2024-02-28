function Get-StairwellAssetList {
    [alias('SwAllAssets')]
    <#
    .SYNOPSIS
    Obtains the all assets for a given Stairwell environment
    .DESCRIPTION
    This function fetches all the assets for your Stairwell environment.
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    If no Environment Id is supplied,this function will attempt to use the Environment Id from the global config.
    .EXAMPLE
    Get-StairwellAssetList
    
    

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId
    )

    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting all Asset Metadata for Environment: $($EnvironmentId)"
        
        if ([string]::IsNullOrEmpty($environmentId)) {
            $EnvId = $script:EnvironmentId
        } else {
            $EnvId = $EnvironmentId.Trim()
        }
        Write-Verbose "Using $($EnvId) for the EnvironmentId."
        
        $Url = $script:baseUri + 'environments/' + $EnvId + '/assets'
        Write-Verbose "Using Url to get asset list: $($Url)"
        
        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
        }
        
        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Asset list returned."
                return $Content.assets
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }

}
