#requires -version 6.2

function Get-StairwellYaraRule {
    [alias('SwRule')]
    <#
    .SYNOPSIS
    Obtains the metadata and definition for a given Yara rule
    .DESCRIPTION
    This function fetches the metadata and definition for a given Yara rule
    .PARAMETER RuleId
    Enter the name of the rule you are seeking information about
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    If no Environment Id is supplied,this function will attempt to use the Environment Id from the global config.
    .EXAMPLE
    Get-StairwellYaraRule -RuleId "My_Sample_Rule"
    
    name             : environments/XXXXXX-XXXXXX-XXXXXX-XXXXXXXX/yaraRules/My_Sample_Rule
    definition       : rule My_Sample_Rule
                       {
                            meta:
                                author = "JT Wells - Stairwell"...
    scanWarning      : 
    state            : STATE_ACTIVE
    updateTime       : 11/1/2023 9:44:56PM
    canaryScanState  : PASSED_CANARY
    tags             : {}

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
        Write-Verbose "Getting Metadata for Yara Rule: $($RuleId)"
        
        $Url = $script:baseUri + 'environments/' + $EnvironmentId + '/yaraRules/' + $RuleId
        Write-Verbose "Using Url to get Yara rule data: $($Url)"
        
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
                Write-Verbose "Yara rule data returned for $($RuleId)."
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