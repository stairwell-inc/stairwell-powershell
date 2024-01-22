#requires -version 6.2

function Remove-StairwellYaraRule {
    [alias('SwDeleteRule')]
    <#
    .SYNOPSIS
    Deletes a Yara rule
    .DESCRIPTION
    This function allows the user to delete an existing Yara rule in their Stairwell environment
    .PARAMETER Name
    The resource name for the Yara rule
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    If no Environment Id is supplied,this function will attempt to use the Environment Id from the global config.
    .EXAMPLE
    Remove-StairwellYaraRule -EnvironmentId <EnvId> -Name MyExampleRule -Force
    #>
    
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory=$true, Position=0,
        HelpMessage="Enter the resource name of the rule you are deleting.")]
        [string]$Name,

        [Parameter(Mandatory=$false, Position=1,
        HelpMessage="Enter the EnvironmentId for the Stairwell environment where the Yara rule will be deleted from.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId,

        [Parameter(Mandatory=$False)]
        [switch]$Force
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Removing Yara Rule: $($Name). WARNING, this cannot be undone."


        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $Script:EnvironmentId
        }
        Write-Verbose "Using $($EnvId) for the EnvironmentId"
        
        if($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }

        $Url = $script:baseUri + 'environments/' + $EnvId + '/yaraRules/' + $Name + '?force=true'
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'DELETE'
            Headers = $script:headers
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        if($PSCmdlet.ShouldProcess($Name,'REMOVE')) {
            try {
                $response = Invoke-WebRequest @ReqParams
                if ($response.StatusCode -eq 200) {
                    Write-Output "Yara rule $($Name) deleted successfully"
                    Write-Verbose "Yara rule $($Name) deleted successfully"
                    Exit
                } else {
                    Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                }
            }
            catch {
                Write-Error -Message $($Error[0].Exception.Message)
            }
        }
    }
}
