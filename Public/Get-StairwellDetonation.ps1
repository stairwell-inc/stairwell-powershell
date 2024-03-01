function Get-StairwellDetonation {
    [alias('GSD')]
    <#
    .SYNOPSIS
    Gets the object detonation report from Stairwell
    .DESCRIPTION
    This function obtains the detonation report for a given objectId
    .PARAMETER ObjectId
    The objectId is the unique identifier for a file/object
    .INPUTS
    Can accept one (1) objectId string
    .EXAMPLE
    Get-StairwellDetonation -ObjectId "aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183"
    
    name             : objects/aa6e3f7403c789d21ceedca3c4792336a035454f6494bb03df8ecbd0ebd7b183/detonation
    tags             : {}
    overview         : 
    rawTriageReports : 
    sampleId         : 
    files            : {@{filename=C:\Windows\Globalization\Sorting\sortdefault.nls; action=ACCESS}, 
                    @{filename=C:\Windows\System32\kernel.appcore.dll; action=ACCESS}, @{filename=\Device\CNG; 
                    action=ACCESS}, @{filename=C:\Windows\WinSxS\SystemResources\gdiplus.dll.mun; action=ACCESS}…}
    registryKeys     : {@{registryKey=HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\CustomLocale\en-US; action=ACCESS; 
                    registryKeyHive=HKEY_LOCAL_MACHINE}, 
                    @{registryKey=HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\ExtendedLocale\en-US; action=ACCESS; 
                    registryKeyHive=HKEY_LOCAL_MACHINE}, 
                    @{registryKey=HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\Sorting\Versions\000603xx; 
                    action=ACCESS; registryKeyHive=HKEY_LOCAL_MACHINE}, 
                    @{registryKey=HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Nls\Sorting\Ids\en-US; action=ACCESS; 
                    registryKeyHive=HKEY_LOCAL_MACHINE}…}
    executedCommands : {"C:\Windows\System32\control.exe"  .\F52eCQQo.lD, control.exe .\F52eCQQo.lD, 
                    C:\Windows\system32\DllHost.exe /Processid:{3EB3C877-1F16-487C-9050-104DBCD66683}, 
                    C:\Windows\system32\wbem\wmiprvse.exe -Embedding…}
    mutexes          : {Local\SM0:6256:168:WilStaging_02, DefaultTabtip-MainUI, Local\SM0:6256:64:WilError_03, 
                    Local\MSCTF.Asm.MutexDefault1…}
    signatures       : {antidebug_setunhandledexceptionfilter, dll_load_uncommon_file_types, injection_rwx, stealth_timeout}
    mitreAttackTtps  : {@{ttp=T1106; signature=antidebug_guardpages}, @{ttp=U0102; signature=antidebug_guardpages}, 
                    @{ttp=T1486; signature=reads_self}, @{ttp=T1486; signature=reads_self}…}
    createdServices  : {}
    startedServices  : {BthAvctpSvc, edgeupdate, gupdate}
    droppedFiles     : {e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855}
    inMemoryFiles    : {}
    detections       : {}
    
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the file/object.")]
        [Alias("File", "Object", "Obj")]
        [ValidatePattern("\w{64}")]
        [string]$ObjectId
    )
    
    begin {
        precheck
        $ObjectId = $ObjectId.Trim()
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting detonation data for $(Compress-ObjectName $ObjectId)"
        
        $Url = $script:baseUri + 'objects/' + $ObjectId.ToLower() + '/detonation'
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
                Write-Verbose "Detonation report found for: $(Compress-ObjectName $ObjectId)"
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
                Write-Verbose "Error fetching detonation for object: $(Compress-ObjectName $ObjectId)"
            }
            
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }
    }
}
