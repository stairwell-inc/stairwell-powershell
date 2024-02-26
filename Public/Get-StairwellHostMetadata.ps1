function Get-StairwellHostMetadata {
    [alias('SwHostMetadata', 'SwHostInfo')]
    <#
    .SYNOPSIS
    Gets the hostname metadata from Stairwell
    .DESCRIPTION
    This function gathers all the metadata for a given hostname
    .PARAMETER Hostname
    The hostname you are seeking information about
    .INPUTS
    Can accept one (1) hostname string
    .EXAMPLE
    Get-StairwellHostMetadata -Hostname "stairwell.com"
    
    name        : hostnames/stairwell.com/metadata
    hostname    : stairwell.com
    aRecords    : {}
    aaaaRecords : {}
    mxRecords   : {}
    tags        : {}
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the Hostname.")]
        [Alias("Host")]
        [ValidatePattern("^([a-zA-Z0-9]+\.)*?[a-zA-Z0-9]+\.[a-zA-Z0-9]+(\.[a-zA-Z0-9]{2,24})?$")]
        [string]$Hostname
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Hostname Metadata for $($Hostname)"
        
        $Url = $script:baseUri + 'hostnames/' + $Hostname.ToLower() + '/metadata'
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
            # Retrieve Hostname Metadata
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error fetching metadata for hostname: $($Hostname)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
