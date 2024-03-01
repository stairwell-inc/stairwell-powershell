function Find-StairwellObjectMetadata {
    [alias('FSOM')]
    <#
    .SYNOPSIS
    Search Stairwell objects using a CEL query
    .DESCRIPTION
    Fetches a list of object metadatas that matches the filter specified in the request.
    .PARAMETER Filter
    CEL string filter which objects must match. https://help.stairwell.com/en/knowledge/how-do-i-write-a-cel-query
    .INPUTS
    Can accept one (1) filter string
    .EXAMPLE
    Find-StairwellObjectMetadata -Filter "mal_eval.malicious == true && asset.count > 0 && asset.count < 10 && object.magic == 'EXE'"
    
    name                   : objects/aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183/metadata
    md5                    : a517d31b55c1ae17c9c9c765f8061b28
    sha1                   : eed76693e15fc68ce40f3e7c8952b99d6e8cdb3b
    sha256                 : aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183
    sha3256                : da957ef656e2bcfdbc5724ca580b6ba6f7d944044c406205be8ad93dcdf29074
    size                   : 1629408
    stairwellFirstSeenTime : 1/31/2023 6:48:15 PM
    tags                   : {}
    detonation             : @{name=objects/aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183/detonation; 
                            tags=System.Object[]; overview=; rawTriageReports=; sampleId=; files=System.Object[]; 
                            registryKeys=System.Object[]; executedCommands=System.Object[]; mutexes=System.Object[]; 
                            signatures=System.Object[]; mitreAttackTtps=System.Object[]; createdServices=System.Object[]; 
                            startedServices=System.Object[]; droppedFiles=System.Object[]; inMemoryFiles=System.Object[]; 
                            detections=System.Object[]}
    malEval                : @{labels=System.Object[]; probabilityBucket=PROBABILITY_VERY_HIGH; severity=HIGH}
    environments           : {BJJKNH-MCGB8F-WAED6B-3ELG8CPJ}
    yaraRuleMatches        : {}
    networkIndicators      : @{ipAddresses=System.Object[]; uninterestingIpAddresses=System.Object[]; 
                            hostnames=System.Object[]; improbableHostnames=System.Object[]; privateHostnames=System.Object[]}
    magic                  : PE32 executable (GUI) Intel 80386, for MS Windows
    mimeType               : application/x-dosexec
    shannonEntropy         : 7.906188
    imphash                : ae9f6a32bb8b03dce37903edbc855ba1
    imphashSorted          : d2d4cdab27467b2a4b701b0161b4ae72
    tlsh                   : bb7523117ac08a71d2b22d3495e8ab74663cbc201fb98bdb53d47a3d4e305d17a3ab53
    objectSignature        : @{x509Certificates=System.Object[]; pkcs7VerificationResult=PKCS7_VERIFICATION_RESULT_UNSPECIFIED}
    ...
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0,
        HelpMessage="Enter the CEL query.")]
        [Alias("Query")]
        [string]$Filter
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Querying Stairwell Objects using: `"$($Filter)`""
        
        $Query = [System.Web.HttpUtility]::UrlEncode($Filter)
        $Url = $script:baseUri + 'objects/metadata?filter=' + $Query
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
        }

        try {
            # Retrieve Base Object Metadata
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error fetching results for filter: $($Filter)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
