function Get-StairwellObjectTags {
    [alias('SwObjTags')]
    <#
    .SYNOPSIS
    Gets the object tags from Stairwell
    .DESCRIPTION
    This function gathers the tags for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Get-StairwellObjectTags -ObjectId "<ObjectId>"
    
    name                                     value      environment      
    ----                                     -----      -----------         
    objects/<ObjectId>/tags/J4M6Y4JYDCIXY=== akira      BJJKNH-MCGB8F-WA…
    objects/<ObjectId>/tags/J4M6Y4JYDCIIG=== ransomware BJJKNH-MCGB8F-WA…
    
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
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Object Tags for $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/tags'
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
                if ($Content.tags.Length -gt 0) {
                    Write-Verbose "Tag data found for object: $(Compress-ObjectName $ObjectId)"
                    return $Content.tags
                } else {
                    # We create an empty object if no data is found
                    $tags = [PSCustomObject]@{
                        name = ''
                        value = ''
                        environment = ''
                    }
                    $Content.tags = $tags
                    Write-Verbose "No tag data found for object: $(Compress-ObjectName $ObjectId)"
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
