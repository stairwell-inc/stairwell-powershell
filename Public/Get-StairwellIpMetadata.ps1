function Get-StairwellIpMetadata {
    [alias('SwIpMetadata', 'SwIpInfo')]
    <#
    .SYNOPSIS
    Gets the IpAddress metadata from Stairwell
    .DESCRIPTION
    This function gathers all the metadata for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress you are seeking information about
    .INPUTS
    Can accept one (1) IpAddress as a string in either ipv4 or ipv6 format
    .EXAMPLE
    Get-StairwellIpMetadata -IpAddress "1.1.1.1"
    
    name        : ipAddresses/1.1.1.1/metadata
    IpAddress   : 1.1.1.1
    tags        : {}
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the IpAddress.")]
        [Alias("Ip")]
        [ValidatePattern("^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$")]
        [string]$IpAddress
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Metadata for $($IpAddress)"
        
        $Url = $script:baseUri + 'ipAddresses/' + $IpAddress + '/metadata'
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            # Retrieve IpAddress Metadata
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error fetching metadata for $($IpAddress)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
