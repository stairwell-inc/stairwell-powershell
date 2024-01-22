function Compress-ObjectName {
    [alias('abv')]
    <#
    .SYNOPSIS
    Shortens the name of Stairwell objects/files
    .DESCRIPTION
    Takes the ObjectId (the sha256 of the object/file) and shortens it from 64 characters to 15 for display simplicity
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object, also the sha256 hash of the object
    .EXAMPLE
    Compress-ObjectName -ObjectId e7762f90024c5366807c7c145d3456f0ac3be086c0ec3557427d3c2c10a2052d

    e7762f...a2052d
    
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "IoC")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId
    )

    begin {}

    process{
        if($null -ne $ObjectId) {
            $FirstPart = $ObjectId.Substring(0,6)
            $EndPart = $ObjectId.Substring(58)

            $ShortId = "$($FirstPart)...$($EndPart)"

            return $ShortId
        } else {
            Write-Error -Message "You must supply a valid SHA256, please check the ObjectId and try again."
        }
    }
}