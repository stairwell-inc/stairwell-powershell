function Get-StairwellHostTags {
    <#
    .SYNOPSIS
    Gets the hostname opinions from Stairwell
    .DESCRIPTION
    This function gathers the opinions for a given Hostname
    .PARAMETER Hostname
    The Hostname
    .INPUTS
    Can accept one (1) Hostname string
    .EXAMPLE
    Get-StairwellHostTags -Hostname "<Hostname>"
    
    verdict                : MALICIOUS
    environment            : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email                  : nobody@stairwell.com
    createTime             : 7/19/2023 10:58:31 PM
    
    #>
    # TODO: VERIFY API FUNCTION

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
        $Hostname = $Hostname.Trim()
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Tags for $($Hostname)"
        
        $Url = $script:baseUri + 'hostnames/' + $Hostname.ToLower() + '/tags'
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                if ($Content.tags.Length -gt 0) {
                    Write-Verbose "Tag data found for $($Hostname)"
                    return $Content.tags
                } else {
                    # We create an empty object if no data is found
                    $tags = [PSCustomObject]@{
                        name = ''
                        value = ''
                        environment = ''
                    }
                    $Content.tags = $tags
                    Write-Verbose "No tag data found for $($Hostname)"
                    return $Content.tags
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
