function Get-StairwellYaraRuleTags {
    [alias('SwRuleTags')]
    <#
    .SYNOPSIS
    Obtains the tag metadata for a given Yara rule
    .DESCRIPTION
    This function fetches the tag metadata for a given Yara rule
    .PARAMETER RuleId
    Enter the name of the rule you are seeking information about
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    If no Environment Id is supplied,this function will attempt to use the Environment Id from the global config.
    .EXAMPLE
    Get-StairwellYaraRuleTags -RuleId "My_Sample_Rule"
    
    name             : environments/XXXXXX-XXXXXX-XXXXXX-XXXXXXXX/yaraRules/My_Sample_Rule/tags/JXXXXXXXXXXXX===
    value            : testyararule
    environment      : XXXXXX-XXXXXX-XXXXXX-XXXXXXXX

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the RuleId/name you are seeking information about.")]
        [Alias("Rule", "Name", "YaraRule")]
        [string]$RuleId,

        [Parameter(Mandatory=$false, Position=1,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId
    )

    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Tags for Yara Rule: $($RuleId)"
        
        $Url = $script:baseUri + 'environments/' + $EnvironmentId + '/yaraRules/' + $RuleId + '/tags'
        Write-Verbose "Using Url to get Yara rule tag data: $($Url)"
        
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
                Write-Verbose "Yara rule tag data returned for $($RuleId)."
                return $Content.tags
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }

}
