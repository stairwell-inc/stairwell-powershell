#requires -version 6.2

function Add-StairwellYaraRuleTag {
    [alias('AddSwYaraRuleTag')]
    <#
    .SYNOPSIS
    Creates a new tag for a Yara rule
    .DESCRIPTION
    This function creates a new tag for a given RuleId
    .PARAMETER RuleId
    The name of the rule you are wanting to apply the tag to
    .PARAMETER Tag
    The value of the tag
    .PARAMETER EnvionmentId
    The environment the tag (and the rule the tag is being applied to) resides in.
    If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .NOTES
    It is important to understand that the rule being tagged MUST be present in your environment.
    Also important to note if you are needing to delete the tag, 
    the TagId that is returned in the response and will be required in order to delete it.
    .EXAMPLE
    Add-StairwellYaraRuleTag -RuleId "<RuleId>" -Tag "rule1234"
    
    name                                                              value    environment
    ----                                                              -----    -----------
    environments/<EnvironmentId>/yaraRules/<RuleId>/tags/<TagId>      rule1234 <EnvironmentId>

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the RuleId/name of the rule you wish to apply the tag to.")]
        [Alias("Rule", "Name", "YaraRule")]
        [string]$RuleId,

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
        Write-Verbose "Adding Tag to Yara Rule: $($RuleId)"


        $Url = $script:baseUri + 'environments/' + $EnvId + '/yaraRules/' + $RuleId + '/tags'
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
                Write-Verbose "Tag creation of $($Tag) successful for: $($RuleId)"
                Write-Verbose "Your TagId is: $($Content.name.Substring($Content.name.Length - 16, 16))"
                return $Content
            } else {
                Write-Verbose "Error creating tag $($Tag) for: $($RuleId)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
