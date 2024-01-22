#requires -version 6.2

function New-StairwellYaraRule {
    [alias('SwNewRule')]
    <#
    .SYNOPSIS
    Add a new Yara rule to the given Stairwell environment
    .DESCRIPTION
    This function allows the user to create a new Yara rule in their Stairwell environment
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    If no Environment Id is supplied,this function will attempt to use the Environment Id from the global config.
    .PARAMETER RuleBody
    The rule contents in string format
    .PARAMETER Name
    The resource name for the Yara rule
    .Parameter Tags
    An array of objects that contain tags that are associated with this rule @(@{value=<TagValue>; environmentId=<EnvId>})
    .EXAMPLE
    New-StairwellYaraRule -EnvironmentId <EnvId> -Name MyExampleRule -RuleBody 'rule ExampleRule {strings: $my_text_string="google.com" condition: $my_text_string}'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,
        HelpMessage="Enter the EnvironmentId for the Stairwell environment where the Yara rule will be created.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId,
        
        [Parameter(Mandatory=$false,
        HelpMessage="Enter the resource name of the rule you are creating.")]
        [string]$Name,

        [Parameter(Mandatory=$true,
        HelpMessage="Enter the rule body you are creating")]
        [string]$RuleBody,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter an array of objects that represent the tag value and the EnvironmentId. Ex. @(@{value=<TagValue>; environmentId=<EnvId>})")]
        [object]$Tags
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Submitting new Yara Rule"
        
        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $Script:EnvironmentId
        }
        Write-Verbose "Using $($EnvId) as the Environment the Yara Rule will belong to."
        
        $Url = $script:baseUri + 'environments/' + $EnvId + '/yaraRules'
        Write-Verbose "Using Url: $($Url)"
        
        $Body = @{'definition' = $RuleBody}
        
        if ($null -ne $Name) {
            Write-Verbose "Rule name: $($Name) was supplied"
            $Body.Add('name', $Name)
        }

        $TagObject = @()
        
        if ($Tags.Length -gt 0) {
            foreach ($tag in $Tags) {
                $TagObject += $tag
            }
            $Body.Add('tags', $TagObject)
        }


        $ReqParams = @{
            Uri = $Url
            Method = 'POST'
            Headers = $script:headers
            Body = ($Body | ConvertTo-Json)
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Yara rule $($Name) uploaded successfully"
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }

    }
}
