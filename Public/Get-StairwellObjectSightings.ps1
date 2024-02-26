function Get-StairwellObjectSightings {
    [alias('SwObjSightings')]
    <#
    .SYNOPSIS
    Gets the object sightings from Stairwell
    .DESCRIPTION
    This function gathers the sightings metadata for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Get-StairwellObjectSightings -ObjectId "aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183"
    
    sightingTime : 8/28/2023 8:35:46 PM
    environment  : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    asset        : assets/JHUQCW-JU56FW-ZC9WC8-N2655HLN
    filename     : sjbki0ekuuvgoqg0qg4dhi5w.exe
    filepath     : C:\users\jumanji\pictures\
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "IoC")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting Object Sightings for $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/sightings'
        Write-Verbose "Using Url: $($Url)"
        
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
                if ($Content.objectSightings.Length -gt 0) {
                    Write-Verbose "Sighting data found for object: $(Compress-ObjectName $ObjectId)"
                    Write-Verbose "Return object type: $($Content.objectSightings.GetType())"
                    return $Content.objectSightings
                } else {
                    Write-Verbose "No sighting data for object: $(Compress-ObjectName $ObjectId)"
                }
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
