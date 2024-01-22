#requires -version 6.2

function Add-StairwellIpOpinion {
    [alias('AddSwIpOpinion')]
    <#
    .SYNOPSIS
    Creates a new opinion for an IpAddress
    .DESCRIPTION
    This function creates a new opinion for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress is the unique identifier for a file/object
    .PARAMETER Opinion
    The opinion [OPINION_VERDICT_UNSPECIFIED, NO_OPINION, TRUSTED, GRAYWARE, MALICIOUS]
    .PARAMETER EnvonmentId
    The environment the opinion will reside within. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) IpAddress in the form of a string in either ipv4 or ipv6 format
    .EXAMPLE
    Add-StairwellIpOpinion -IpAddress "<IpAddress>" -Opinion "TRUSTED"
    
    verdict environment                   email                            createTime
    ------- -----------                   -----                            ----------
    TRUSTED <EnvironmentId>               example@stairwell.com            1/12/2023 2:08:43 PM

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the IpAddress.")]
        [Alias("Ip")]
        [ValidatePattern("^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$")]
        [string]$IpAddress,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
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
        Write-Verbose "Adding Opinion to Ip: $($IpAddress)"
        
        $Url = $script:baseUri + 'ipAddresses/' + $IpAddress + '/opinions'
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
                Write-Verbose "Creation of opinion $($Opinion) successful for: $($IpAddress)"
                return $Content
            } else {
                Write-Verbose "Error creating opinion $($Opinion) for: $($IpAddress)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
