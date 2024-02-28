function Add-StairwellHostTag {
    [alias('AddSwHostTag')]
    <#
    .SYNOPSIS
    Creates a new tag for a hostname
    .DESCRIPTION
    This function creates a new tag for a given Hostname
    .PARAMETER Hostname
    The Hostname is the unique identifier for a file/object
    .PARAMETER Tag
    The value of the tag
    .PARAMETER EnvonmentId
    The environment the tag (and the object the tag is being applied to) resides in. If no EnvironmentId is supplied then the EnvironmentId in the global config will be used.
    .INPUTS
    Can accept one (1) Hostname string
    .NOTES
    Important to note if you are needing to delete the tag, the TagId that is returned in the response will be required.
    .EXAMPLE
    Add-StairwellHostTag -Hostname "<Hostname>" -Tag "Case1234"
    
    name                                      value     environment
    ----                                      -----     -----------
    hostname/<Hostname>/tags/JABCDEFGHIJKL=== Case1234  <EnvironmentId>

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the Hostname.")]
        [Alias("Host")]
        [ValidatePattern("^([a-zA-Z0-9]+\.)*?[a-zA-Z0-9]+\.[a-zA-Z0-9]+(\.[a-zA-Z0-9]{2,24})?$")]
        [string]$Hostname,

        [Parameter(Mandatory, Position=1, ValueFromPipeline,
        HelpMessage="Enter the name/value of the tag.")]
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
        Write-Verbose "Adding Tag to hostname: $($Hostname)"
        
        $Url = $script:baseUri + 'hostnames/' + $Hostname.ToLower() + '/tags'
        Write-Verbose "Using Url: $($Url)"
        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $script:EnvironmentId
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
                Write-Verbose "Tag creation of $($Tag) successful for: $($Hostname)"
                Write-Verbose "Your TagId is: $($Content.name.Substring($Content.name.Length - 16, 16))"
                return $Content
            } else {
                Write-Verbose "Error creating tag $($Tag) for: $($Hostname)"
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
