function Remove-StairwellHostTag {
    [alias('SwDeleteHostTag')]
    <#
    .SYNOPSIS
    Deletes the specified tag for a hostname
    .DESCRIPTION
    This function deletes the specified tag for a given Hostname
    .PARAMETER Hostname
    The Hostname the tag is applied to
    .PARAMETER TagId
    The value of the TagId typically seen when the tag was applied or by using Get-StairwellObjectTags
    It is a 16 character value: 13 alphanumeric characters followed by three (3) equals (=) signs ex. "JBC1DEF23GH89==="
    .INPUTS
    Can accept one (1) Hostname string
    .NOTES
    The TagId is used as a URL param and therefore will be URL encoded but this module will accept both encoded and unencoded values
    There is no visible output from a successful deletion, use -verbose if confirmation is needed.
    .EXAMPLE
    Remove-StairwellHostTag -Hostname "<Hostname>" -Tag "JBC1DEF23GH89==="

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the Hostname.")]
        [Alias("Host")]
        [ValidatePattern("^([a-zA-Z0-9]+\.)*?[a-zA-Z0-9]+\.[a-zA-Z0-9]+(\.[a-zA-Z0-9]{2,24})?$")]
        [string]$Hostname,

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
        Write-Verbose "Removing Host Tag $($TagId) from $($Hostname)"
        
        if ($TagId -match '\w{13}\%3D\%3D\%3D') {
            $TagIdEnc = $TagId
            Write-Verbose "Using $($TagIdEnc)"
        } elseif ($TagId -match '\w{13}\=\=\=') {
            $TagIdEnc = $TagId -replace '\=\=\=', '%3D%3D%3D'
            Write-Verbose "Using $($TagIdEnc)"
        } else {
            Write-Error "Invalid TagId format. Valid Example: JXX1XXX23XX45==="
        }

        $Url = $script:baseUri + 'hostnames/' + $Hostname.ToLower() + '/tags/' + $TagIdEnc
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'DELETE'
            Headers = $script:headers
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response | ConvertFrom-Json
                Write-Verbose "Tag deletion of TagId $($TagId) successful for: $($Hostname)"
                return $Content
            } else {
                Write-Verbose "Error deleting TagId $($TagId) for: $($Hostname)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
