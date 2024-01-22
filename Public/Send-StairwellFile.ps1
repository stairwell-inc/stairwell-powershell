#requires -version 6.2

# Define function to make an API request to upload a file
function Send-StairwellFile {
    <#
    .SYNOPSIS
    Function that sends files to Stairwell for analysis.
    .DESCRIPTION
    This 2 step process first requests an upload of the file's SHA256 to determine uniqueness, if approved, the 2nd request sends the file to Stairwell
    .PARAMETER AssetID
    The asset identifier that will be attributed with uploading the file. Every environment has at least one asset. If no value is provided the default asset associated with the environemnt_id in the config will be used.
    .PARAMETER FilePath
    The full path of the file to be uploaded.
    .PARAMETER Detonate
    Switch used to trigger a file detonation upon successful upload. Defaults to $False
    .INPUTS
    Can accept a $FilePath from a pipe
    .OUTPUTS
    System.String indicating if the file/object has been successfully uploaded.
    .EXAMPLE
    Send-StairwellFile -FilePath "C:\Users\jdoe\AppData\Local\Something\Test.exe"
    File "Test.exe" was successfully uploaded.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the full path and filename of the file you want to send to Stairwell")]
        [Alias("File", "Object", "IoC")]
        [ValidatePattern("(^\~?((\.{2}\/{1})+|((\.{1}\/{1})?)|(\/{1}))(([a-zA-Z0-9]+\/{1})+)([a-zA-Z0-9])+(\.{1}[a-zA-Z0-9]+)?$|^(\w\:|\\\\)(\\?\\?[a-zA-Z0-9\_\~\-\s\.\%]+\\?\\?)+([a-zA-Z0-9\_\~\-\.]+\.[a-zA-Z0-9]+)$)")]
        [string]$FilePath,

        [Parameter(Mandatory = $false, Position=1, ValueFromPipeline)]
        [string]$AssetID,

        [Parameter(Mandatory = $false)]
        [switch]$Detonate
    )

    begin {
        precheck

        $FileName = Split-Path $FilePath -leaf
        # Obtain SHA256 and MD5 hash values for file
        try {
            $FileSha256 = (Get-FileHash -Path $FileName).ToLower()
            Write-Verbose "Obtained SHA256 hash $FileSha256 from $FileName successfully."
            $FileMD5 = (Get-FileHash -Path $FileName -Algorithm MD5).ToLower()
            Write-Verbose "Obtained hash $FileMD5 from $FileName successfully."
        } catch {
            Write-Error "An error occured calculating the file hash for $FileName $_." -ErrorAction Stop
        }

        # If no $AssetID is supplied, we check to see if one is already defined within the module scope, if there is we use it
        # If no $AssetID exists in the module scope we use Get-StairwellDefaultAsset which uses the environment_id from the module config to get the DefaultAsset for that environment
        if($null = $AssetID) {
            if($null = $Script:DefaultAsset) {
                $AssetID = Get-StairwellDefaultAsset
                Write-Verbose "No Default Asset defined, calling Get-StairwellDefault Asset using the environment_id in the config: $(AssetId)"
            } else {
                Write-Verbose "Using the default asset defined in the config $($Script:DefaultAsset)"
                $AssetID = $Script:DefaultAsset
            }
        }

        # Set the detonation flag on the upload if the -Detonate switch is used
        if($Detonate) {
            $Detonation = "DETONATE"
        } else {
            $Detonation = "DETONATION_PLAN_UNSPECIFIED"
        }

    } # End Begin

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Sending file/object to Stairwell: $($FileName)"


        # Read the file into memory
        try {
            $FileBytes = [System.IO.File]::ReadAllBytes( $(resolve-path $FilePath) )
            $FileContent = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($FileBytes)
        } catch {
            Write-Error "Error reading the file $($FileName) into memory. Please try again."
        } 

        
        $Url = 'https://http.intake.app.stairwell.com/v2021.05/upload'
        
        # Create the 1st stage body payload
        $Stage1Body = @{
            'asset' = @{'id' = $AssetId}
            'files' = @(
                @{
                    'filePath' = $FilePath
                    'expected_attributes' = @{'identifiers' = @(@{'sha256' = $FileHash256.ToLower()}, @{'md5' = $FileHashMD5.ToLower()})}
                }
            )
        }
        Write-Verbose "Using Stage 1 payload: $RequestBody"
        Write-Verbose "Using Uri: $Url"
        
        try {
            # Attempt the 1st stage of the upload
            $Response1 = Invoke-WebRequest -Uri $Url -Method POST -Body ($Stage1Body | ConvertTo-Json) -TimeoutSec 60 -MaximumRetryCount 5 -RetryIntervalSec 1 -ErrorAction Stop
            $StatusCode = $Response1.StatusCode
            Write-Verbose "Stage 1 Status Code: $($StatusCode)"
        } catch [System.Net.WebException] {
            Write-Verbose -Message $($Error[0].Exception.Message)
        }

        # If 1st stage is successful continue, otherwise throw an error
        if ($response1.StatusCode -eq 200) {
            $Content1 = $response1.Content | ConvertFrom-Json
            $Stage1Action = $Content1.fileActions[0].action
            $StatusCode = $Response.StatusCode
            
            # If the upload is approved, continue with uploading the file by constructing the payload from elements in the 1st stage response body.
            if ($Stage1Action -eq "UPLOAD") {
                Write-Verbose "Upload requested"
                $UploadUrl = $Content1.fileActions[0].uploadUrl
                Write-Verbose "Using Upload URL: $($UploadUrl)"
    
                # Taking the 'fields' array from the 1st stage response content for our payload
                $Fields = $Content1.fileActions[0].fields
    
                
                # Construct the multipart form. This is ugly but works until I find a prettier way. Note that indenting the code wrecks everything. You've been warned.
                $boundary = [guid]::NewGuid().ToString()
                $MPC = @'
--{0}
Content-Disposition: form-data; name="key"
Content-Type: text/plain; charset=utf-8

{1}
--{0}
Content-Disposition: form-data; name="policy"
Content-Type: text/plain; charset=utf-8

{2}
--{0}
Content-Disposition: form-data; name="x-goog-algorithm"
Content-Type: text/plain; charset=utf-8

{3}
--{0}
Content-Disposition: form-data; name="x-goog-credential"
Content-Type: text/plain; charset=utf-8

{4}
--{0}
Content-Disposition: form-data; name="x-goog-date"
Content-Type: text/plain; charset=utf-8

{5}
--{0}
Content-Disposition: form-data; name="x-goog-meta-asset-id"
Content-Type: text/plain; charset=utf-8

{6}
--{0}
Content-Disposition: form-data; name="x-goog-meta-file-detonate"
Content-Type: text/plain; charset=utf-8

{7}
--{0}
Content-Disposition: form-data; name="x-goog-meta-file-format"
Content-Type: text/plain; charset=utf-8

{8}
--{0}
Content-Disposition: form-data; name="x-goog-meta-file-path"
Content-Type: text/plain; charset=utf-8

{9}
--{0}
Content-Disposition: form-data; name="x-goog-meta-md5"
Content-Type: text/plain; charset=utf-8

{10}
--{0}
Content-Disposition: form-data; name="x-goog-meta-sha256"
Content-Type: text/plain; charset=utf-8

{11}
--{0}
Content-Disposition: form-data; name="x-goog-signature"
Content-Type: text/plain; charset=utf-8

{12}
--{0}
Content-Disposition: form-data; name="file"; filename="{13}"
Content-Type: application/octet-stream

{14}
--{0}--
'@  # End making multipart form content

                $Body = $MPC -f $boundary, $Fields.key, $Fields.policy, $Fields.'x-goog-algorithm', $Fields.'x-goog-credential', $Fields.'x-goog-date', $Fields.'x-goog-meta-asset-id', $Detonation, $Fields.'x-goog-meta-file-format', $Fields.'x-goog-meta-file-path', $Fields.'x-goog-meta-md5', $Fields.'x-goog-meta-sha256', $Fields.'x-goog-signature', $FileName, $FileContent
                
                # Attempt the 2nd stage upload
                try {
                    $response2 = Invoke-WebRequest -Uri $UploadUrl -Method POST -Headers $headers -ContentType "multipart/form-data; boundary=$($boundary)" -Body $Body -TimeoutSec 300 -MaximumRetryCount 5 -RetryIntervalSec 1 -ErrorAction Stop
                } catch [System.Net.WebException] {
                    Write-Verbose -Message $($Error[0].Exception.Message)
                }
                
                $StatusCode = $Response2.StatusCode
                Write-Verbose "Stage 2 Status Code: $($StatusCode)"
                
                # 2nd stage upload only returns a 204 and nothing else if successful
                if($Response2.StatusCode -eq 204) {
                    Write-Information -Message "File $($FileName) was successfully uploaded."
                }
                
                $Response2
            } else {
                Write-Verbose "File $($FileName) already exists in your environment. Upload request denied."
            } # End if statement from stage 1 file action UPLOAD check

        } else {
            Write-Error -Message "Error; Response Code: $($StatusCode)"
            Write-Verbose -Message $($Error[0].Exception.Message)
        } # End if statement from stage 1 response code check

    } # End Process

} # End Function