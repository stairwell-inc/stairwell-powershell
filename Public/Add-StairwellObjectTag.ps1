function Add-StairwellObjectTag {
    [alias('AddSwObjTag')]
    <#
    .SYNOPSIS
    Creates a new tag for an object
    .DESCRIPTION
    This function creates a new tag for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .PARAMETER Tag
    The value of the tag
    .PARAMETER EnvonmentId
    The environment the comment (and the object the tag is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) objectId string
    .NOTES
    It is important to understand that the object being tagged MUST be present in your environment.
    You cannot make changes to objects that are not part of your environment, that includes global objects.

    Also important to note if you are needing to delete the tag, the TagId that is returned in the response will be required.
    .EXAMPLE
    Add-StairwellObjectTag -ObjectId "<SHA256>" -Tag "Case1234"
    
    name                               value    environment
    ----                               -----    -----------
    objects/<ObjectId>/tags/<TagId>=== TestTag2 <EnvironmentId>

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "Obj")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
        HelpMessage="Enter the name of the tag.")]
        [string]$Tag,

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
        Write-Verbose "Adding Tag to object: $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/tags'
        Write-Verbose "Using Url: $($Url)"
        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $script:EnvironmentId
        }
        Write-Verbose "Using $($EnvId) for the Environment Id"
        
        $Body = @{
            "value" = $Tag
            "environment" = $EnvId
        }

        $ReqParams = @{
            Uri = $Url
            Method = 'POST'
            Headers = $script:headers
            Body = $($Body | ConvertTo-Json)
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Tag creation of $($Tag) successful for: $(Compress-ObjectName $ObjectId)"
                Write-Verbose "Your TagId is: $($Content.name.Substring($Content.name.Length - 16, 16))"
                return $Content
            } else {
                Write-Verbose "Error creating tag $($Tag) for object: $(Compress-ObjectName $ObjectId)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
