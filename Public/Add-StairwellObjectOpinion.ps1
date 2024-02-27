function Add-StairwellObjectOpinion {
    [alias('AddSwObjOpinion')]
    <#
    .SYNOPSIS
    Creates a new opinion for an object
    .DESCRIPTION
    This function creates a new opinion for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .PARAMETER Opinion
    The opinion [OPINION_VERDICT_UNSPECIFIED, NO_OPINION, TRUSTED, GRAYWARE, MALICIOUS]
    .PARAMETER EnvonmentId
    The environment the opinion (and the object the opinion is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) objectId string
    .NOTES
    It is important to understand that the object's opinion being set MUST be present in your environment.
    You cannot make changes to objects that are not part of your environment, that includes global objects.
    .EXAMPLE
    Add-StairwellObjectOpinion -ObjectId "<SHA256>" -Opinion "TRUSTED"
    
    verdict environment                   email                            createTime
    ------- -----------                   -----                            ----------
    TRUSTED <EnvironmentId>               example@stairwell.com            1/12/2023 2:08:43 PM

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "Obj")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId,

        [Parameter(Mandatory, Position=1,
        HelpMessage="Enter the opinion: OPINION_VERDICT_UNSPECIFIED, NO_OPINION, TRUSTED, GRAYWARE, MALICIOUS")]
        [Alias("Verdict")]
        [ValidateSetAttribute("OPINION_VERDICT_UNSPECIFIED", "NO_OPINION", "TRUSTED", "GRAYWARE", "MALICIOUS")]
        [string]$Opinion,

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
        Write-Verbose "Adding opinion to object: $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/opinions'
        Write-Verbose "Using Url: $($Url)"
        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $script:EnvironmentId
        }
        Write-Verbose "Using $($EnvId) for the Environment Id"
        
        $Body = @{
            "verdict" = $Opinion.ToUpper()
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
                Write-Verbose "Creation of $($Opinion) successful for: $(Compress-ObjectName $ObjectId)"
                return $Content
            } else {
                Write-Verbose "Error creating Opinion $($Opinion) for object: $(Compress-ObjectName $ObjectId)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
