function Get-StairwellHostOpinions {
    [alias('SwHostOpinions')]
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
    Get-StairwellHostOpinions -Hostname "<Hostname>"
    
    verdict                : MALICIOUS
    environment            : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email                  : nobody@stairwell.com
    createTime             : 7/19/2023 10:58:31 PM
    
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
        Write-Verbose "Getting Opinions for $($Hostname)"
        
        $Url = $script:baseUri + 'hostname/' + $Hostname.ToLower() + '/opinions'
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
        }

        try {
            # Retrieve Base Object Metadata
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                if ($Content.opinions.Length -gt 0) {
                    Write-Verbose "Opinion data found for $($Hostname)"
                    return $Content.opinions
                } else {
                    # We create an empty object if not data is found
                    $opinions = [PSCustomObject]@{
                        verdict = 'NO OPINION'
                        environment = ''
                        email = ''
                        createTime = ''
                    }
                    $Content.opinions = $opinions
                    Write-Verbose "No opinion data found for $($Hostname)"
                    return $Content.opinions
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
