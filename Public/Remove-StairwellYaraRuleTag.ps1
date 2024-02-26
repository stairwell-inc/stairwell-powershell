function Remove-StairwellYaraRuleTag {
    [alias('SwDeleteRuleTag')]
    <#
    .SYNOPSIS
    Deletes the specified tag for a Yara rule
    .DESCRIPTION
    This function deletes the specified tag for a given RuleId
    .PARAMETER RuleId
    The name of the rule you are wanting to remove the tag from
    .PARAMETER TagId
    The value of the TagId typically seen when the tag was applied or by using Get-StairwellYaraRuleTags
    It is a 16 character value: 13 alphanumeric characters followed by three (3) equals (=) signs ex. "JBC1DEF23GH89==="
    .NOTES
    It is important to understand that the rule and tag being deleted MUST be present in your environment.
    The TagId is used as a URL param and therefore will be URL encoded but this module will accept both encoded and unencoded values
    There is no visible output from a successful deletion, use -verbose if confirmation is needed.
    .EXAMPLE
    Remove-StairwellYaraRuleTag -RuleId "<TagId>" -Tag "JBC1DEF23GH89==="

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the RuleId/name of the rule you wish to apply the tag to.")]
        [Alias("Rule", "Name", "YaraRule")]
        [string]$RuleId,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
        HelpMessage="Enter the tag ID Example: JXX1XXX23XX45===")]
        [ValidatePattern("\w{13}(\=\=\=|\%3D\%3D\%3D)")]
        [string]$TagId
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Removing Tag $($TagId) from $($RuleId)"
        
        if ($TagId -match '\w{13}\%3D\%3D\%3D') {
            $TagIde = $TagId
        } elseif ($TagId -match '\w{13}\=\=\=') {
            $TagIde = $TagId -replace '\=\=\=', '%3D%3D%3D'
        } else {
            Write-Error "Invalid TagId format. Valid Example: JXXXXXXXXXXXX==="
        }
        Write-Verbose "Using $($TagIde)"

        $Url = $script:baseUri + 'environments/' + $EnvId + '/yaraRules/' + $RuleId + '/tags/' + $TagIde
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'DELETE'
            Headers = $script:headers
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response | ConvertFrom-Json
                Write-Verbose "Tag deletion of TagId $($TagId) successful for rule: $($RuleId)"
                return $Content
            } else {
                Write-Verbose "Error deleting TagId $($TagId) for rule: $($RuleId)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
