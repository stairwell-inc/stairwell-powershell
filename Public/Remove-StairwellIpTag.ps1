function Remove-StairwellIpTag {
    [alias('SwDeleteIpTag')]
    <#
    .SYNOPSIS
    Deletes the specified tag for a IpAddress
    .DESCRIPTION
    This function deletes the specified tag for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress the tag is applied to
    .PARAMETER TagId
    The value of the TagId typically seen when the tag was applied or by using Get-StairwellIpTags
    It is a 16 character value: 13 alphanumeric characters followed by three (3) equals (=) signs ex. "JBC1DEF23GH89==="
    .INPUTS
    Can accept one (1) IpAddress as a string in either ipv4 or ipv6 format
    .NOTES
    The TagId is used as a URL param and therefore will be URL encoded but this module will accept both encoded and unencoded values
    There is no visible output from a successful deletion, use -verbose if confirmation is needed.
    .EXAMPLE
    Remove-StairwellIpTag -IpAddress "<IpAddress>" -Tag "JBC1DEF23GH89==="

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the IpAddress.")]
        [Alias("Ip")]
        [ValidatePattern("^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$")]
        [string]$IpAddress,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
        HelpMessage="Enter the tag ID Example: JXX1XXX23XX45===")]
        [ValidatePattern("\w{13}(\=\=\=|\%3D\%3D\%3D)")]
        [string]$TagId
    )
    
    begin {
        precheck
        $TagId = $TagId.Trim()
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Removing Tag $($TagId) from $($IpAddress)"
        
        if ($TagId -match '\w{13}\%3D\%3D\%3D') {
            $TagIdEnc = $TagId
            Write-Verbose "Using $($TagIdEnc)"
        } elseif ($TagId -match '\w{13}\=\=\=') {
            $TagIdEnc = $TagId -replace '\=\=\=', '%3D%3D%3D'
            Write-Verbose "Using $($TagIdEnc)"
        } else {
            Write-Error "Invalid TagId format. Valid Example: JXX1XXX23XX45==="
        }

        $Url = $script:baseUri + 'ipAddresses/' + $IpAddress + '/tags/' + $TagIdEnc
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
                Write-Verbose "Tag deletion of TagId $($TagId) successful for: $($IpAddress)"
                return $Content
            } else {
                Write-Verbose "Error deleting TagId $($TagId) for: $($IpAddress)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
