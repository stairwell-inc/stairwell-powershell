function Add-StairwellHostComment {
    <#
    .SYNOPSIS
    Creates a new comment for a hostname
    .DESCRIPTION
    This function creates a new comment for a given Hostname
    .PARAMETER Hostname
    The Hostname is the unique identifier for a file/object
    .PARAMETER Comment
    The body of the comment
    .PARAMETER EnvonmentId
    The environment the comment (and the object the comment is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) Hostname string
    .EXAMPLE
    Add-StairwellHostComment -Hostname "<Hostname>" -Comment "This is a test comment" -EnvironmentId "<ENVIRONMENT-ID>"
    
    
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the Hostname.")]
        [Alias("Host")]
        [ValidatePattern("^([a-zA-Z0-9]+\.)*?[a-zA-Z0-9]+\.[a-zA-Z0-9]+(\.[a-zA-Z0-9]{2,24})?$")]
        [string]$Hostname,

        [Parameter(Mandatory, Position=1,
        HelpMessage="Enter the comment for the file/object.")]
        [string]$Comment,

        [Parameter(Mandatory=$false, Position=2,
        HelpMessage="Enter the EnvironmentId for your Stairwell environment.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId
    )
    
    begin {
        precheck
        $Hostname = $Hostname.Trim()
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Adding Comment to host: $($Hostname)"
        
        $Url = $script:baseUri + 'hostnames/' + $Hostname.ToLower() + '/comments'
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
                Write-Verbose "Comment $($Comment) applied to $($Hostname)"
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error applying comment to $($Hostname)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
