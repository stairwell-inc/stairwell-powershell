#requires -version 6.2

function Get-StairwellIpComments {
    [alias('SwIpComments')]
    <#
    .SYNOPSIS
    Gets the IpAddress comments from Stairwell
    .DESCRIPTION
    This function gathers the comments for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress you are seeking comments for.
    .INPUTS
    Can accept one (1) IpAddress in the form of a string in either ipv4 or ipv6 format
    .EXAMPLE
    Get-StairwellIpComments -IpAddress "<IpAddress>"
    
    body         : This is a comment.
    environment  : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email        : nobody@stairwell.com
    createTime   : 1/12/2023 2:08:43 PM
    
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
        Write-Verbose "Getting Comments for $($IpAddress)"
        
        $Url = $script:baseUri + 'ipAddresses/' + $IpAddress + '/comments'
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
                if ($Content.comments.Length -gt 0) {
                    Write-Verbose "Comment data found for IpAddress: $($IpAddress)"
                    return $Content.comments
                } else {
                    # We create an empty object if no data is found
                    $comments = [PSCustomObject]@{
                        body = ''
                        email = ''
                        createTime = ''
                        environment = ''
                    }
                    $Content.comments = $comments
                    Write-Verbose "No comment data found for IpAddress: $($IpAddress)"
                    return $Content.comments
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
