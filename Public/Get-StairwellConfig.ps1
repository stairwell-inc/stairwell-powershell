#requires -version 6.2

function Get-StairwellConfig {
    <#
    .SYNOPSIS
    Gets the curretnly active Stairwell environment variables
    .DESCRIPTION
    This function returns the
    .PARAMETER ClearText
    Switch to enable clear text for the API token's value
    .EXAMPLE
    Get-StairwellConfig
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [Switch]$ClearText
    )

    begin {
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Getting the environment config for the Stairwell module."
        if ($Null -eq $script:ApiToken -and $Null -eq $script:EnvironmentId) {
            Write-Verbose "No config. Exiting."
            Write-Output "No config. Please run Set-StairwellConfig to complete the config first."
            break
        }


        if ($Null -eq $script:DefaultAsset) {
            Write-Verbose "Missing Default AssetId. Using Get-StairwellDefaultAsset"
            Get-StairwellDefaultAsset
        }

        if (($null -eq $script:ApiToken) -or ($null -eq $script:EnvironmentId)) {
            if ($script:ApiToken) {
                Write-Output "Missing EnvironmentId. Please run Set-StairwellConfig to complete the config."
            } else {
                Write-Output "Missing ApiToken. Please run Set-StairwellConfig to complete the config."
            }        
        } else {
            if($ClearText) {
                Write-Output "API Token: $($script:ApiToken)"
            } else {
                Write-Output "API Token (obfuscated): $($script:ApiToken.Substring(0,6)+"..."+$($script:ApiToken.Substring(46)))"
            }
            Write-Output "EnvironmentID: $($script:EnvironmentId)"
            Write-Output "Default AssetId: $($script:DefaultAsset)"
        }
    }
}