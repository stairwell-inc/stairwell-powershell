#requires -version 6.2

function Get-StairwellAsset {
    [alias('SwAsset')]
    <#
    .SYNOPSIS
    Obtains the assets infomation for a given AssetId
    .DESCRIPTION
    This function fetches the asset information for the provided AssetId.
    .PARAMETER AssetId
    Enter the Asset Id you are seeking information about.
    .EXAMPLE
    Get-StairwellAsset -AssetId "XXXXXX-XXXXXX-XXXXXX-XXXXXXXX"
    
    name             : assets/XXXXXX-XXXXXX-XXXXXX-XXXXXXXX
    label            : devbox1
    createTime       : 9/12/2023 10:06:57PM
    lastCheckinTime  : 9/12/2023 10:06:57PM
    environment      : AAAAAA-BBBBBB-CCCCCC-DDDDDDDD
    forwarderVersion : 1.3.5
    macAddress       : 00:00:00:00:00:00
    os               : Windows
    osVersion        : 10.0.19044
    tags             : {}
    uploadToken      : XXXXXX-XXXXXX-XXXXXX-XXXXXXXX

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the AssetId you are seeking information about.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$AssetId
    )

    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Asset Metadata for $($AssetId)"

        $Url = $script:baseUri + 'assets/' + $AssetId
        Write-Verbose "Using Url to get asset data: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Asset data returned for: $($AssetId)."
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