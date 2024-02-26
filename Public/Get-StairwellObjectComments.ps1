function Get-StairwellObjectComments {
    [alias('SwObjComments')]
    <#
    .SYNOPSIS
    Gets the object comments from Stairwell
    .DESCRIPTION
    This function gathers the comments metadata for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Get-StairwellObjectComments -ObjectId "aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183"
    
    body         : This is a comment.
    environment  : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email        : nobody@stairwell.com
    createTime   : 1/12/2023 2:08:43 PM
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "IoC")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId
    )
    
    begin {
        precheck
    }

    process {
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/comments'
        Write-Verbose "-------------------------------------------"
        
        Write-Verbose "Getting Object Comments for $(Compress-ObjectName $ObjectId)"
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
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                if ($Content.comments.Length -gt 0) {
                    Write-Verbose "Comment data found for object: $(Compress-ObjectName $ObjectId)"
                    return $Content.comments
                } else {
                    Write-Verbose "No comment data found for object: $(Compress-ObjectName $ObjectId)"
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
