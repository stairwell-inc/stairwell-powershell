#requires -version 6.2

function Add-StairwellHostOpinion {
    [alias('AddSwHostOpinion')]
    <#
    .SYNOPSIS
    Creates a new opinion for an object
    .DESCRIPTION
    This function creates a new opinion for a given Hostname
    .PARAMETER Hostname
    The Hostname is the unique identifier for a file/object
    .PARAMETER Opinion
    The opinion [OPINION_VERDICT_UNSPECIFIED, NO_OPINION, TRUSTED, GRAYWARE, MALICIOUS]
    .PARAMETER EnvonmentId
    The environment the opinion (and the hostname the opinion is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) Hostname string
    .EXAMPLE
    Add-StairwellHostOpinion -Hostname "<Hostname>" -Opinion "TRUSTED"
    
    verdict environment                   email                            createTime
    ------- -----------                   -----                            ----------
    TRUSTED <EnvironmentId>               example@stairwell.com            1/12/2023 2:08:43 PM

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the Hostname.")]
        [Alias("Host")]
        [ValidatePattern("^([a-zA-Z0-9]+\.)*?[a-zA-Z0-9]+\.[a-zA-Z0-9]+(\.[a-zA-Z0-9]{2,24})?$")]
        [string]$Hostname,

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
        Write-Verbose "Adding Opinion to host: $($Hostname)"
        
        $Url = $script:baseUri + 'objects/' + $Hostname.ToLower() + '/opinions'
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
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Creation of opinion $($Opinion) successful for: $($Hostname)"
                return $Content
            } else {
                Write-Verbose "Error creating opinion $($Opinion) for: $($Hostname)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
