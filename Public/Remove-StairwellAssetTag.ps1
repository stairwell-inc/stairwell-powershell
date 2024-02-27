function Remove-StairwellAssetTag {
    [alias('SwDeleteAssetTag')]
    <#
    .SYNOPSIS
    Deletes the specified tag for an asset
    .DESCRIPTION
    This function deletes the specified tag for a given AssetId
    .PARAMETER AssetId
    The AssetId is the unique identifier for an asset/endpoint
    .PARAMETER TagId
    The value of the TagId typically seen when the tag was applied or by using Get-StairwellAssetTags
    It is a 16 character value: 13 alphanumeric characters followed by three (3) equals (=) signs ex. "JBC1DEF23GH89==="
    .INPUTS
    Can accept one (1) AssetId string.
    .NOTES
    It is important to understand that the asset tag being deleted MUST be present in your environment.
    The TagId is used as a URL param and therefore will be URL encoded but this module will accept both encoded and unencoded values
    There is no visible output from a successful deletion, use -verbose if confirmation is needed.
    .EXAMPLE
    Remove-StairwellAssetTag -AssetId "<TagId>" -Tag "JBC1DEF23GH89==="

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the AssetId you wish to apply the tag to.")]
        [Alias("Asset", "Endpoint")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$AssetId,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
        HelpMessage="Enter the tag ID Example: JXX1XXX23XX45===")]
        [ValidatePattern("\w{13}(\=\=\=|\%3D\%3D\%3D)")]
        [string]$TagId
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Removing Asset Tag $($TagId) from $($AssetId)"
        
        if ($TagId -match '\w{13}\%3D\%3D\%3D') {
            $TagIde = $TagId
            Write-Verbose "Using $($TagIde)"
        } elseif ($TagId -match '\w{13}\=\=\=') {
            $TagIde = $TagId -replace '\=\=\=', '%3D%3D%3D'
            Write-Verbose "Using $($TagIde)"
        } else {
            Write-Error "Invalid TagId format. Valid Example: JXX1XXX23XX45==="
        }

        $Url = $script:baseUri + 'assets/' + $AssetId.ToLower() + '/tags/' + $TagIde
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'DELETE'
            Headers = $script:headers
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response | ConvertFrom-Json
                Write-Verbose "Tag deletion of TagId $($TagId) successful for asset: $($AssetId)"
                return $Content
            } else {
                Write-Verbose "Error deleting TagId $($TagId) for asset: $($AssetId)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
