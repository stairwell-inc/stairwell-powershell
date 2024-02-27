function Get-StairwellObjectOpinions {
    [alias('SwObjOpinions')]
    <#
    .SYNOPSIS
    Gets the object opinions from Stairwell
    .DESCRIPTION
    This function gathers the opinions for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Get-StairwellObjectOpinions -ObjectId "aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183"
    
    verdict                : MALICIOUS
    environment            : ADBCEF-123456-ZYXXWV-987654-GHIJKLMN
    email                  : nobody@stairwell.com
    createTime             : 7/19/2023 10:58:31 PM
    
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
        Write-Verbose "Getting Object opinions for $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/opinions'
        Write-Verbose "Using Url: $($Url)"
        
        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                if ($Content.opinions.Length -gt 0) {
                    Write-Verbose "Opinion data found for object: $(Compress-ObjectName $ObjectId)"
                    return $Content.opinions
                } else {
                    # We create an empty object if not data is found
                    $opinions = [PSCustomObject]@{
                        verdict = 'NO OPINION'
                        environment = ''
                        email = ''
                        createTime = ''
                    }
                    $Content.opinions = $opinions
                    Write-Verbose "No opinion data found for object: $(Compress-ObjectName $ObjectId)"
                    return $Content.opinions
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
