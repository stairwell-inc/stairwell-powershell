function Add-StairwellObjectComment {
    [alias('SwObjComment')]
    <#
    .SYNOPSIS
    Creates a new comment for an object
    .DESCRIPTION
    This function creates a new comment for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .PARAMETER Comment
    The body of the comment
    .PARAMETER EnvonmentId
    The environment the comment (and the object the comment is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) objectId string
    .NOTES
    It is important to understand that the object being commented on MUST be present in your environment.
    You cannot make changes to objects that are not part of your environment, that includes global objects.
    .EXAMPLE
    Add-StairwellObjectComment -ObjectId "<SHA256>" -Comment "This is a test comment" -EnvironmentId "<ENVIRONMENT-ID>"
    
    
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "Obj")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId,

        [Parameter(Mandatory, Position=1,
        HelpMessage="Enter the comment for the file/object.")]
        [string]$Comment,

        [Parameter(Mandatory=$false, Position=2,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Adding Comment to ObjectId $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/comments'
        Write-Verbose "Using Url: $($Url)"
        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $script:EnvironmentId
        }
        Write-Verbose "Using $($EnvId) for the Environment Id"
        
        $Body = @{
            "body" = $Comment
            "environment" = $EnvId
        }

        $ReqParams = @{
            Uri = $Url
            Method = 'POST'
            Headers = $script:headers
            Body = $($Body | ConvertTo-Json)
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Comment $($Comment) applied to object: $(Compress-ObjectName $ObjectId)"
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error applying comment to object: $(Compress-ObjectName $ObjectId)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
