#requires -version 6.2

function Get-StairwellHostComments {
    [alias('SwObjComments')]
    <#
    .SYNOPSIS
    Gets the object comments from Stairwell
    .DESCRIPTION
    This function gathers the comments metadata for a given Hostname
    .PARAMETER Hostname
    The Hostname is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) Hostname string
    .EXAMPLE
    Get-StairwellHostComments -Hostname "<Hostname>"
    
    body         : This is a comment.
    environment  : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email        : nobody@stairwell.com
    createTime   : 1/12/2023 2:08:43 PM
    
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
        Write-Verbose "Getting Comments for hostname: $($Hostname)"
        
        $Url = $script:baseUri + 'hostnames/' + $Hostname.ToLower() + '/comments'
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
                    Write-Verbose "Comment data found for hostname: $($Hostname)"
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
                    Write-Verbose "No comment data found for hostname: $($Hostname)"
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
