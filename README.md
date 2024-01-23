![Stairwell, Inc.](https://github.com/stairwell-inc/stairwell-powershell/blob/main/Stairwell_Primary-Logo_RGB.png)

### stairwell-powershell is a PowerShell module used to aid in the utilization of the Stairwell platform. stairwell-powershell is comprised of the following functions:

## Assets/Forwarders

**Manage and get insights about your active Stairwell forwarders.**

#### `Add-StairwellAssetTag`

Creates and applies a new tag for an asset.

#### `Get-StairwellAsset`

Obtains the asset infomation for a given AssetId.

#### `Get-StairwellAssetList`

Obtains the all assets for a given Stairwell environment

#### `Get-StairwellAssetTags`

Obtains the asset's tag infomation for a given AssetId

#### `Get-StairwellDefaultAsset`

Obtains the default asset id for a given Stairwell environment

#### `Remove-StairwellAssetTag`

Deletes the specified tag for an asset

#### `Install-StairwellForwarder`

Installs the Stairwell forwarder on one or many Windows OS machines.

## Objects/Files

**Tools for analyzing, classifying, or interacting with objects/files.**

#### `Add-StairwellObjectComment`

Creates a new comment for an object.

#### `Add-StairwellObjectOpinion`

Creates and applies a new opinion for an object.

#### `Add-StairwellObjectTag`

Creates and applies a new tag for an object.

#### `Find-StairwellObjectMetadata`

Search all Stairwell objects using a CEL query.

#### `Get-StairwellDetonation`

Gets the object detonation report from Stairwell.

#### `Get-StairwellObjectComments`

Gets the comments for a given object from Stairwell.

#### `Get-StairwellObjectMetadata`

Gets the object metadata from Stairwell which includes: file size, various hash values, malEval analysis, Yara rule matches, etc.

#### `Get-StairwellObjectOpinions`

Gets the most recent object opinion from Stairwell

#### `Get-StairwellObjectSightings`

Gets the object sightings (if any in the working environment) from Stairwell.

#### `Get-StairwellObjectTags`

Gets the object tags from Stairwell.

#### `Get-StairwellObjectVariants`

Gets the object variants (statistically similar files) from Stairwell

#### `Invoke-StairwellAnalysis`

(Beta) Perform a full analysis on a collection of objects using the Stairwell platform. Uploads new files and reports affected assets.

#### `Invoke-StairwellDetonation`

Triggers a new detonation for the parent object.

#### `Receive-StairwellObject`

Downloads the full object to the user's local device.

#### `Remove-StairwellObjectTag`

Deletes the specified tag for an object

#### `Send-StairwellFile`

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

#### `Get-StairwellHostMetadata`

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

#### `Get-StairwellIpMetadata`

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

#### `Get-StairwellYaraRule`

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

#### `Get-StairwellConfig`

Gets the curretnly active Stairwell environment variables.

#### `Set-StairwellConfig`

Enables the Stairwell module by accepting the Stairwell Environment ID and API Token.

## Usage

Refer to the comment-based help in each individual script for detailed usage information.

To install this module, drop the entire stairwell-powershell folder into one of your module directories. The default PowerShell module paths are listed in the $Env:PSModulePath environment variable.

The default per-user module path is: "$Env:HomeDrive$Env:HOMEPATH\Documents\WindowsPowerShell\Modules"
The default computer-level module path is: "$Env:windir\System32\WindowsPowerShell\v1.0\Modules"

To use the module, type `Import-Module Stairwell`

To see the commands imported, type `Get-Command -Module Stairwell`

(C) Stairwell 2024 | Author: JT Wells
