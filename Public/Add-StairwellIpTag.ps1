function Add-StairwellIpTag {
    <#
    .SYNOPSIS
    Creates a new tag for a IpAddress
    .DESCRIPTION
    This function creates a new tag for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress is the tag will be applied to
    .PARAMETER Tag
    The value of the tag
    .PARAMETER EnvonmentId
    The environment the tag will reside in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) IpAddress as a string in either ipv4 or ipv6 format
    .NOTES
    Important to note if you are needing to delete the tag, the TagId that is returned in the response will be required.
    .EXAMPLE
    Add-StairwellIpTag -IpAddress "<IpAddress>" -Tag "Case1234"
    
    name                                      value     environment
    ----                                      -----     -----------
    ipaddress/<IpAddress>/tags/JABCDEFGHIJKL=== Case1234  <EnvironmentId>

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the IpAddress.")]
        [Alias("Ip")]
        [ValidatePattern("^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$")]
        [string]$IpAddress,

        [Parameter(Mandatory, Position=1,
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
        Write-Verbose "Adding Tag to Ip: $($IpAddress)"
        
        $Url = $script:baseUri + 'ipAddresses/' + $IpAddress + '/tags'
        Write-Verbose "Using Url: $($Url)"
        if ([string]::IsNullOrEmpty($environmentId)) {
            $EnvId = $script:EnvironmentId
        } else {
            $EnvId = $EnvironmentId.Trim()
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
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Tag creation of $($Tag) successful for: $($IpAddress)"
                Write-Verbose "Your TagId is: $($Content.name.Substring($Content.name.Length - 16, 16))"
                return $Content
            } else {
                Write-Verbose "Error creating tag $($Tag) for: $($IpAddress)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
