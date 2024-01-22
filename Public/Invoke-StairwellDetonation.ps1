#requires -version 6.2

function Invoke-StairwellDetonation {
    [alias('SwDetonate')]
    <#
    .SYNOPSIS
    Triggers a new detonation for the parent object.
    .DESCRIPTION
    This function obtains the detonation report for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .PARAMETER ParentObject
    The objectId of the parent resource where this detonation will be triggered.
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Invoke-StairwellDetonation -ObjectId "bafaf6eba3313a6cd60179e6fab90cdd9004448a0e6ff64783057f2d25ae18ed"
    
    name             : objects/bafaf6eba3313a6cd60179e6fab90cdd9004448a0e6ff64783057f2d25ae18ed/detonation
    tags             : {}
    overview         : 
    rawTriageReports : 
    sampleId         : 
    files            : {}
    registryKeys     : {}
    executedCommands : {}
    mutexes          : {}
    signatures       : {}
    mitreAttackTtps  : {}
    createdServices  : {}
    startedServices  : {}
    droppedFiles     : {}
    inMemoryFiles    : {}
    detections       : {}
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "Obj")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId,

        [Parameter(Mandatory=$false, Position=1, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the parent file/object where the detonation will be triggered.")]
        [Alias("File", "Parent", "ParentObj")]
        [ValidatePattern("\w{64}")]
        [string]$ParentObject
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Invoking detonation of Object: $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/detonation:trigger'
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'POST'
            Headers = $script:headers
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            if ($null -ne $ParentObject) {
                Write-Verbose "Parent Object supplied $(Compress-ObjectName $ParentObject)"
                $Body = @{parent=$ParentObject}
                $ReqParams['Body'] = ($Body | ConvertTo-Json)
                $response = Invoke-WebRequest @ReqParams
                $Content = $response.Content | ConvertFrom-Json
                return $Content
            } else {
                $response = Invoke-WebRequest @ReqParams
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Submission for detonation requested. This will take several minutes to complete."
                return $Content
            }
            
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
