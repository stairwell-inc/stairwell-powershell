function Install-StairwellForwarder {
    <#
    .SYNOPSIS
    Installs the Stairwell forwarder on one or many Windows OS machines.
    .DESCRIPTION
    Installs the Stairwell forwarder on one or many Windows OS machines.
    .PARAMETER ComputerNames
    An array of ComputerNames the forwarder is to be installed on.
    .PARAMETER FilePath
    The full file path on the Stairwell installer.
    .PARAMETER DestFolderPath
    If copying the installer package to a remote computer the installer is copied into this directory.
    .PARAMETER ForwarderToken
    The Stairwell file forwarder token for the environment the forwarder will be associated with.
    .PARAMETER EnvironmentId
    The Stairwell EnvironmentId for the environment the forwarder will be associated with.
    .PARAMETER MaxThreads
    If you want to install on multiple computers in parallel, indicate the max number of simultaneous connections.
    .PARAMETER Download
    If you wish to download the latest Windows installer package use this switch.
    .PARAMETER NoBackscan
    If you wish to install the forwarder but prevent it from performing a full backscan of all physical drives, use this switch.
    .PARAMETER ThrottleLimit
    Specifies the maximum number of concurrent connections that can be established at one time. Default is 32
    .INPUTS
    Can accept an array of ComputerNames
    .EXAMPLE

    #>

    [CmdletBinding()]
        param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline,
        HelpMessage="Enter the ComputerNames you wish to install the Stairwell forwarder on.")]
        [string[]]$ComputerNames,

        [Parameter(Mandatory,
        HelpMessage="Enter the path to the package installer OR the folder it should be downloaded to if downloading the latest version.")]
        [ValidatePattern("^([a-zA-Z]:?)([\/]{0,2})?([a-zA-Z0-9\s\+\`\~\!\@\#\$\%\^\&\(\)\_\-\+\=\{\}\[\]\;\'\/\.\,\<\>]{1,128})*?$")]
        [string]$FilePath,

        [Parameter(Mandatory=$False,
        HelpMessage="Enter the path/folder where the file will be copied to on the remote computer. 'C:\Temp' will be used by default.")]
        [ValidatePattern("^([a-zA-Z]:?)([\/]{0,2})?([a-zA-Z0-9\s\+\`\~\!\@\#\$\%\^\&\(\)\_\-\+\=\{\}\[\]\;\'\/\.\,\<\>]{1,128})*?$")]
        [string]$DestFolderPath="C:\Temp\InceptionForwarderBundle.exe",

        [Parameter(Mandatory,
        HelpMessage="Enter the Stairwell file forwarder token for your environment.")]
        [string]$ForwarderToken,

        [Parameter(Mandatory,
        HelpMessage="Enter the EnvironmentId the forwarder with be associated with.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId,

        [Parameter(Mandatory=$False,
        HelpMessage="Enter the maximum number of simultaneous install sessions. Default is 1")]
        [ValidateRange(1,99)]
        [int]$MaxThreads=1,

        [Parameter(Mandatory=$False)]
        [switch]$Download,

        [Parameter(Mandatory=$False)]
        [switch]$NoBackscan,

        [Parameter(Mandatory=$False)]
        [int]$ThrottleLimit=32
    )

    begin {}

    process {
        
        $FilePath = Join-Path $FilePath "InceptionForwarderBundle.exe"

        # Check for -Download switch
        if($Download) {
            try {  
                $ProgressPreference = 'SilentlyContinue'  
                Invoke-WebRequest -Uri "https://downloads.stairwell.com/windows/latest/InceptionForwarderBundle.exe" -OutFile $FilePath
            }  
            catch {  
                Write-Error "Error downloading the Stairwell forwarder installer. Error $($PSItem)"  
                exit 1  
            }
        }

        # If the user opts to install the forwarder w/o performing an initial backscan
        if($NoBackscan) {
            $InstallArgs = "/install", "ENVIRONMENT_ID=$($EnvironmentId)", "TOKEN=$($ForwarderToken)", "DOSCAN=0", "/quiet", "/norestart", "/log log.txt"
        } else {
            $InstallArgs = "/install", "ENVIRONMENT_ID=$($EnvironmentId)", "TOKEN=$($ForwarderToken)", "/quiet", "/norestart", "/log log.txt"
        }
        
        # Create a new PowerShell session to the remote computer(s)
        $Session = New-PSSession -ComputerName @ComputerNames -ThrottleLimit $ThrottleLimit

        # This is the installer script
        $Scriptblock = {
            Param([object]$Session, [string]$DestFolderPath, [string]$FilePath, [array]$InstallArgs)
            
            #Create the destination folder if not already exist
            Invoke-Command -Session $Session -ScriptBlock {
                param($DestFolderPath)
                if (!(Test-Path $DestFolderPath)) {
                    New-Item -ItemType Directory -Path $DestFolderPath
                }
            } -ArgumentList $DestFolderPath

            # Copy the software installation package to the remote computer
            Copy-Item $FilePath -Destination $DestFolderPath -ToSession $Session

            # Install the Software silently on the remote computer
            Invoke-Command -Session $Session -ScriptBlock {
            param($FilePath,$InstallArgs)
            Start-Process -FilePath $FilePath -Wait -NoNewWindow -ArgumentList @InstallArgs} -ArgumentList $FilePath,$InstallArgs

            # Remove the installation package from the remote computer
            Invoke-Command -Session $Session -ScriptBlock { 
            param($FilePath) 
            Remove-Item $FilePath -Force } -ArgumentList $FilePath


            # Close the PowerShell session to the remote computer
            Remove-PSSession $Session
        }

        # Perform the install of the forwarder
        try {
            Invoke-Command $Scriptblock -ArgumentList [object]$Session, [string]$DestFolderPath, [string]$FilePath, [array]$InstallArgs
            Write-Host "Installation of Stairwell forwararder on $($ComputerNames.Length) Computers is completed."
        }
        catch {
            Write-Error "Error installing the Stairwell forwarder. Error: $($PSItem)"
        }
        
    }
}