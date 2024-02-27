function Get-StairwellObjectVariants {
    [alias('SwObjVariants')]
    <#
    .SYNOPSIS
    Gets the object variants from Stairwell
    .DESCRIPTION
    This function gathers the variants metadata for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Get-StairwellObjectVariants -ObjectId "e7762f90024c5366807c7c145d3456f0ac3be086c0ec3557427d3c2c10a2052d"
    
    variant                                            similarity
    -------                                            ----------
    @{name=objects/objects/8b655c994af725d67616879...  0.96875
    @{name=objects/objects/4b454e17e8edacc037f5ee8...  0.98215
    @{name=objects/objects/98fdc857eb972b72c744abb...  0.9625
    @{name=objects/objects/facd3852bd8d36de79ba2b2...  0.9625
    ...
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
        Write-Verbose "Getting Object Variants for $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/variants'
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
                if ($Content.objectVariants.Length -gt 0) {
                    Write-Verbose "Variants data found for object: $(Compress-ObjectName $ObjectId)"
                    return $Content.objectVariants
                } else {
                    Write-Verbose "No variants found for object: $(Compress-ObjectName $ObjectId)"
                    return $Content
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
