function Add-StairwellIpComment {
    <#
    .SYNOPSIS
    Creates a new comment for a IpAddress
    .DESCRIPTION
    This function creates a new comment for a given IpAddress
    .PARAMETER IpAddress
    The IpAddress the comment will be applied to
    .PARAMETER Comment
    The body of the comment
    .PARAMETER EnvonmentId
    The environment the comment (and the object the comment is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) IpAddress string
    .EXAMPLE
    Add-StairwellIpComment -IpAddress "<IpAddress>" -Comment "This is a test comment" -EnvironmentId "<ENVIRONMENT-ID>"
    
    
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the IpAddress.")]
        [Alias("Ip")]
        [ValidatePattern("^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$")]
        [string]$IpAddress,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
        HelpMessage="Enter the comment for the IpAddress.")]
        [string]$Comment,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Adding Comment to IP: $($IpAddress)"
        
        $Url = $script:baseUri + 'ipAddressses/' + $IpAddress + '/comments'
        Write-Verbose "Using Url: $($Url)"
        if ([string]::IsNullOrEmpty($environmentId)) {
            $EnvId = $script:EnvironmentId
        } else {
            $EnvId = $EnvironmentId.Trim()
        }
        Write-Verbose "Using $($EnvId) for the Environment Id"
        
        $Body = @{
            "body" = $Comment
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
                Write-Verbose "Comment $($Comment) applied to $($IpAddress)"
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error applying comment to $($IpAddress)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
