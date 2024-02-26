function Receive-StairwellObject {
    [alias('SwDownload', 'SwDownloadObject', 'SwDownloadFile')]
    <#
    .SYNOPSIS
    Downloads the object to the user's local device
    .DESCRIPTION
    This function allows the user to download the object requested
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .PARAMETER Path
    The Path serves as both the location the object is saved to as well as the file name. If not supplied,
    the path will be the local directory and the filename will be chosen for you (see notes)
    .INPUTS
    Can accept one (1) objectId string but will output the result(s) into the local directory if no $Path is specified
    .NOTES
    When no $Path is provided this module will attempt to find a previously seen file name from your environment and use that.
    If no sightings are available, the file/object is simply named the SHA256 Object ID without an extension.
    .EXAMPLE
    Receive-StairwellObject -ObjectId "aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183" -Path "./myfile.exe"
    
    <binary object>
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "Obj")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId,

        [Parameter(Mandatory=$false, Position=1, ValueFromPipeline,
        HelpMessage="Full path the downloaded object should save to including file name.")]
        [Alias("FilePath", "Fullpath")]
        [string]$Path
    )
    
    begin {
        precheck
    } # End begin block

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Downloading Object: $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + ':download'
        Write-Verbose "Using Url: $($Url)"

        $ReqParams = @{
            Uri = $Url
            Method = 'GET'
            Headers = $script:headers
            TimeoutSec = 240
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "File obtained for object: $(Compress-ObjectName $ObjectId)"
                
                if ($null -ne $Path) {
                    Write-Verbose "Using file path $($Path)"
                    return $Content | Out-File -FilePath $Path

                } else {
                    # If no $Path is supplied try and see if the file has been seen in the current environment to keep the file name aligned correctly
                    $Sightings = Get-StairwellObjectSightings -ObjectId $ObjectId
                    
                    if ($Sightings.Length -gt 0) {
                        $Filename = $Sightings[0].filename
                        Write-Verbose "No file path supplied, using current directory and filename: $($Filename)"
                        return $Content | Out-File -FilePath $(".\" + $Filename)

                    } else {
                        # If the file comes from our global archive it won't have a file name and thus will be named whatever the ObjectId is w/o an extension
                        Write-Verbose "No path provided, no sightings to use for file names, output will be named $(Compress-ObjectName $ObjectId) no extension in the current directory."
                        return $Content | Out-File -FilePath $(".\" + $ObjectId)
                        
                    }
                }
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error fetching object: $(Compress-ObjectName $ObjectId)"
            } # End status code 200 check
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        } # End try/catch block

    } # End process block

} # End function block
