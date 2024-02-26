function Get-StairwellIpOpinions {
    [alias('SwIpOpinions')]
    <#
    .SYNOPSIS
    Gets the IpAddress opinions from Stairwell
    .DESCRIPTION
    This function gathers the opinions for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress
    .INPUTS
    Can accept one (1) IpAddress as a string in either ipv4 or ipv6 format
    .EXAMPLE
    Get-StairwellIpOpinions -IpAddress "<IpAddress>"
    
    verdict                : MALICIOUS
    environment            : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email                  : nobody@stairwell.com
    createTime             : 7/19/2023 10:58:31 PM
    
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
        Write-Verbose "Getting Opinions for $($IpAddress)"
        
        $Url = $script:baseUri + 'ipAddresses/' + $IpAddress + '/opinions'
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
            # Retrieve Base Object Metadata
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                if ($Content.opinions.Length -gt 0) {
                    Write-Verbose "Opinion data found for $($IpAddress)"
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
                    Write-Verbose "No opinion data found for $($IpAddress)"
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
