#requires -version 6.2

function Get-StairwellAssetTags {
    [alias('SwAssetTags')]
    <#
    .SYNOPSIS
    Obtains the asset's tag infomation for a given AssetId
    .DESCRIPTION
    This function fetches the asset's tags.
    .PARAMETER AssetId
    Enter the Asset Id you are seeking information about.
    .EXAMPLE
    Get-StairwellAssetTags -AssetId "XXXXXX-XXXXXX-XXXXXX-XXXXXXXX"
    
    name             : assets/XXXXXX-XXXXXX-XXXXXX-XXXXXXXX/tags/JXXXXXXXXXXXX===
    value            : devboxes
    environment      : AAAAAA-BBBBBB-CCCCCC-DDDDDDDD

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the AssetId you are seeking tag values for.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$AssetId
    )

    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Tags for Asset: $($AssetId)"
        
        $Url = $script:baseUri + 'assets/' + $AssetId
        Write-Verbose "Using Url to get asset tags: $($Url)"

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
                Write-Verbose "Asset tag data returned."
                return $Content.tags
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }

}