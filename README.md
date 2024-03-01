![Stairwell, Inc.](https://github.com/stairwell-inc/stairwell-powershell/blob/main/Stairwell_Primary-Logo_RGB.png)

### stairwell-powershell is a PowerShell module to aid in the utilization of the Stairwell platform. stairwell-powershell is comprised of the following cmdlets:

## Assets/Forwarders

**Manage and get insights about your active Stairwell forwarders.**

#### `Add-StairwellAssetTag`

Creates and applies a new tag for an asset.

#### `Get-StairwellAsset` - alias (GSwA)

Obtains the asset infomation for a given AssetId.

#### `Get-StairwellAssetList` - alias (GSAL)

Obtains the all assets for a given Stairwell environment

#### `Get-StairwellAssetTags`

Obtains the asset's tag infomation for a given AssetId

#### `Get-StairwellDefaultAsset` - alias (GSAL)

Obtains the default asset id for a given Stairwell environment

#### `Remove-StairwellAssetTag`

Deletes the specified tag for an asset

## Objects/Files

**Tools for analyzing, classifying, or interacting with objects/files.**

#### `Add-StairwellObjectComment` - alias (ASOC)

Creates a new comment for an object.

#### `Add-StairwellObjectOpinion` - alias (ASOO)

Creates and applies a new opinion for an object.

#### `Add-StairwellObjectTag` - alias (ASOT)

Creates and applies a new tag for an object.

#### `Find-StairwellObjectMetadata` - alias (FSOM)

Search all Stairwell objects using a CEL query.

#### `Get-StairwellDetonation` - alias (GSD)

Gets the object detonation report from Stairwell.

#### `Get-StairwellObjectComments` - alias (GSOC)

Gets the comments for a given object from Stairwell.

#### `Get-StairwellObjectMetadata` - alias (GSOM)

Gets the object metadata from Stairwell which includes: file size, various hash values, malEval analysis, Yara rule matches, etc.

#### `Get-StairwellObjectOpinions` - alias (GSOO)

Gets the most recent object opinion from Stairwell

#### `Get-StairwellObjectSightings` - alias (GSOS)

Gets the object sightings (if any in the working environment) from Stairwell.

#### `Get-StairwellObjectTags` - alias (GSOT)

Gets the object tags from Stairwell.

#### `Get-StairwellObjectVariants`

Gets the object variants (statistically similar files) from Stairwell

#### `Invoke-StairwellDetonation` - alias (Detonate)

Triggers a new detonation for the parent object.

#### `Receive-StairwellObject` - alias (RSO)

Downloads the full object to the user's local device.

#### `Remove-StairwellObjectTag`

Deletes the specified tag for an object

#### `Send-StairwellFile` - alias (SSwF)

Function that sends files to Stairwell for analysis.

## Hosts/Domains

**Analyze and investigate hosts and domains associated to objects**

#### `Add-StairwellHostComment`

Creates and applies a new comment for a hostname.

#### `Add-StairwellHostOpinion`

Creates and applies a new opinion for an object.

#### `Add-StairwellHostTag`

Creates and applies a new tag for a hostname.

#### `Get-StairwellHostComments`

Gets the host comments from Stairwell.

#### `Get-StairwellHostMetadata` - alias (GSHM)

Gets the hostname metadata from Stairwell.

#### `Get-StairwellHostOpinions`

Gets the hostname opinions from Stairwell.

#### `Get-StairwellHostTags`

Gets the hostname opinions from Stairwell.

#### `Remove-StairwellHostTag`

Deletes the specified tag for a hostname.

## IPs

**Analyze and investigate IP addresses associated to objects.**

#### `Add-StairwellIpComment`

Creates a new comment for a IpAddress.

#### `Add-StairwellIpOpinion`

Creates and applies a new opinion for an IpAddress.

#### `Add-StairwellIpTag`

Creates and applies a new tag for a IpAddress.

#### `Get-StairwellIpComments`

Gets the IpAddress comments from Stairwell.

#### `Get-StairwellIpMetadata` - alias (GIPM)

Gets the IpAddress metadata from Stairwell.

#### `Get-StairwellIpOpinions`

Gets the current IpAddress opinion from Stairwell.

#### `Remove-StairwellIpTag`

Deletes the specified tag for a IpAddress.

## Yara Rules

**Use Yara Rules to instantly hunt and search across all assets and author new detections.**

#### `Add-StairwellYaraRuleTag`

Creates and applies a new tag for a Yara rule.

#### `Edit-StairwellYaraRule`

Edits/updates a given Yara rule.

#### `Get-StairwellYaraRule` - alias (GSYR)

Obtains the metadata and definition for a given Yara rule.

#### `Get-StairwellYaraRuleTags`

Obtains the tag metadata for a given Yara rule.

#### `New-StairwellYaraRule`

Add a new Yara rule to the given Stairwell environment

#### `Remove-StairwellYaraRule`

Deletes a Yara rule.

#### `Remove-StairwellYaraRuleTag`

Deletes the specified tag for a Yara rule.

## Misc

**Miscellaneous helper functions**

#### `Get-StairwellConfig` - alias (GSwC)

Gets the curretnly active Stairwell environment variables.

#### `Set-StairwellConfig` - alias (SSwC)

Enables the Stairwell module by accepting the Stairwell Environment ID and API Token.

## Usage

Refer to the comment-based help in each individual script for detailed usage information.

To install this module, drop the entire stairwell-powershell folder into one of your module directories. The default PowerShell module paths are listed in the $Env:PSModulePath environment variable.

The default per-user module path is: "$Env:HomeDrive$Env:HOMEPATH\Documents\WindowsPowerShell\Modules"
The default computer-level module path is: "$Env:windir\System32\WindowsPowerShell\v1.0\Modules"

Depending on execution policy and where you store this module, you may need to run `Get-ChildItem <path to this module folder> -recurse | Unblock-File`

To use the module, type `Import-Module Stairwell` or `Import-Module -Path <path to this module folder>`

To see the commands imported, type `Get-Command -Module Stairwell`

(C) Stairwell 2024 | Author: JT Wells
