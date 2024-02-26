function Invoke-StairwellAnalysis {
    <#
    .SYNOPSIS
    Perform a full Stairwell analysis on a collection of objects
    .DESCRIPTION
    This function accepts one or more objects and returns all the data Stairwell has for each, in addition to recursing through all variants that include a sighting
    .PARAMETER ObjectIds
    Enter the ObjectIds (SHA256) as an array
    .PARAMETER Paths
    Enter the paths as an array to the files you want analyzed
    .PARAMETER RecursionDepth
    Enter the number of recursion levels to stop at for finding matching variants of variants. Default=1
    .PARAMETER OnlySightings
    Switch parameter that filters the returned result set to only output IoCs (and their variants) that have a sighting on one of your assets. Defaults to $False
    .PARAMETER Threshold
    Optional parameter to set as the minimum percentage match for variants. Default is zero (all matches), use with caution.
    .PARAMETER UploadNew
    Optional switch parameter to automatically upload new\unique files found from a supplied path
    .EXAMPLE
    Invoke-StairwellAnalysis -ObjectIds @(<SHA256_1>, <SHA256_2>)
    <CustomPSObject containing results>

    Invoke-StairwellAnalysis -Paths @("C:\Users\jdoe\AppData\Local\Something\Test.exe") -UploadNew
    <CustomPSObject containing results>

    .NOTES
    It is highly suggested to run this in -Verbose mode to be able to see the progress and the final report of the analysis which includes 
    a list of assets that have a sighting of any the ObjectIds (or their variants) that have a malicious MalEval score or have an Opinion
    of 'MALICIOUS'.

    The final object has a NoteProperty called 'AffectedAssets' that contains an array of the asset machine names that have a malicious sighting.
    
    Be aware this is a multi-threaded module that is making a series of API calls for each object supplied in order to be performant.
    A high number of ObjectIds and increasing the RecursionDepth can have a noticable impact of resource usage and time required.

    Also be aware that ObjectIds are shortened for display purposes only
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False,
        ValueFromPipeline,
        HelpMessage="Enter the SHA256 for the files/objects in the form of an array.")]
        [Alias("Files", "Objects", "IoCs")]
        [ValidatePattern("\w{64}")]
        [string[]]$ObjectIds,

        [Parameter(Mandatory=$False,
        ValueFromPipeline,
        HelpMessage="Enter the full path and filename of the file you want to investigate in the form of an array")]
        [ValidatePattern("(^\~?((\.{2}\/{1})+|((\.{1}\/{1})?)|(\/{1}))(([a-zA-Z0-9]+\/{1})+)([a-zA-Z0-9])+(\.{1}[a-zA-Z0-9]+)?$|^(\w\:|\\\\)(\\?\\?[a-zA-Z0-9\_\~\-\s\.\%]+\\?\\?)+([a-zA-Z0-9\_\~\-\.]+\.[a-zA-Z0-9]+)$)")]
        [string[]]$Paths,

        [Parameter(Mandatory=$False,
        HelpMessage="Enter the max number of recursions on variants of variants.")]
        [Alias("Depth")]
        [int]$RecursionDepth=1,

        [Parameter(Mandatory=$False,
        HelpMessage="Enter the max number of recursions on variants of variants.")]
        [Alias("Seen","SightingsOnly","OnlySeen")]
        [switch]$OnlySightings,

        [Parameter(Mandatory=$False,
        HelpMessage="Enter the numeric value for the minimum percentage allowed for a variant match 1..100")]
        [Alias("Match")]
        [ValidateRange(1,99)]
        [int]$Threshold=1,

        [Parameter(Mandatory=$False,
        HelpMessage="Use this switch to automatically upload new files.")]
        [switch]$UploadNew
    )

    begin {
        precheck
    } # End begin block

    process {
        # We need to make sure we have access to the apiToken and environmentId in this scope as we will be feeding them into the separate multithread jobs
        $apiToken = $script:apiToken
        $EnvironmentId = $script:EnvironmentId
        $Results = [PSCustomObject]@{}
        $AffectedAssets = [System.Collections.ArrayList]::new()
        

        # If we have paths, try to resolve them fully before getting a hash for them
        if($Null -ne $Paths) {
            foreach($Path in $Paths) {
                try {
                    $Path = Resolve-Path $Path
                    $ObjId = (Get-FileHash $Path).Hash
                    
                    # Once we can resole the path and hash the file, we add the hash to the ObjectIds array for investigation
                    if($Null -ne $ObjId) {
                        [array]$ObjectIds += $ObjId
                        if($UploadNew) {
                            Send-StairwellFile -File $Path
                        }
                    }
                } catch {
                    Write-Error -Message $($Error[0].Exception.Message)
                } # End try/catch block that resolves paths and sends new files block

            } # End foreach $Paths enumeration

        } # End if $Paths block

        
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Starting analysis of the supplied $($ObjectIds.Count) IoC(s)."
        Write-Verbose "This may take a few moments or longer depending on the number of ObjectIds and RecursionDepth."
        $TotalCount = 0
        $SightingCount = 0
        foreach($IoC in $ObjectIds) {
            $Depth = $RecursionDepth
            $Result = [PSCustomObject]@{}
            
            # Multi-threading setup
            $Jobs = @()

            # Start with Metadata, if none is found stop right there, otherwise we continue to enrich the $IoC
            $Metadata = Get-StairwellObjectMetadata -ObjectId $IoC -ErrorAction SilentlyContinue
            if($Null -ne $Metadata) {
                Write-Verbose "Metadata found for $(Compress-ObjectName $IoC)"
                $Result = $Metadata # Results in a PSCustomObject

                # Thread the separate API calls
                $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock { Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId; $Sightings = Get-StairwellObjectSightings -ObjectId $using:IoC -ErrorAction SilentlyContinue; return $Sightings } -Name SightingsJob
                $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock { Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId; $Opinions = Get-StairwellObjectOpinions -ObjectId $using:IoC -ErrorAction SilentlyContinue; return $Opinions } -Name OpinionsJob
                $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock { Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId; $Comments = Get-StairwellObjectComments -ObjectId $using:IoC -ErrorAction SilentlyContinue; return $Comments } -Name CommentsJob
                $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock { Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId; $Variants = Get-StairwellObjectVariants -ObjectId $using:IoC -ErrorAction SilentlyContinue; return $Variants } -Name VariantsJob
                
                Start-Sleep -Milliseconds 100
                while ((Get-Job -Name 'SightingsJob','OpinionsJob','CommentsJob','VariantsJob' -IncludeChildJob | Where-Object {$_.State -ne "Completed"}).Count -gt 0) {Start-Sleep -Milliseconds 100} 6>$Null
                # $Null = Get-Job -Name 'SightingsJob','OpinionsJob','CommentsJob','VariantsJob' | Wait-Job

                foreach ($Job in $Jobs) {
                    if($Job.name -eq 'SightingsJob' -and $Job.State -eq "Completed") {
                        $Sightings = Receive-Job -Job $Job -Wait
                        
                        # Check for sightings
                        if($Null -ne $Sightings) {
                            $SightingCount += $Sightings.Length
                            Write-Verbose "Sighting(s) found for $(Compress-ObjectName $IoC)"
                            Add-Member -InputObject $Result -NotePropertyName 'sightings' -NotePropertyValue $Sightings
                        } elseif($SightingsOnly) {
                            Write-Verbose "No sightings for $(Compress-ObjectName $IoC) and $SightingsOnly switch turned on. Ending search here."
                            continue
                        } # End $Sightings null check / $Sightings only check

                    } elseif($Job.name -eq 'OpinionsJob' -and $Job.State -eq "Completed") {
                        $Opinions = Receive-Job -Job $Job -Wait
                        
                        # Check for opinions
                        if($Null -ne $Opinions) {
                            Write-Verbose "Opinion found for $(Compress-ObjectName $Ioc)"
                            Add-Member -InputObject $Result -NotePropertyName opinions -NotePropertyValue $Opinions
                        } # End $Opinions null check

                    } elseif($Job.name -eq 'CommentsJob' -and $Job.State -eq "Completed") {
                        $Comments = Receive-Job -Job $Job -Wait
                        
                        # Check for comments
                        if($Null -ne $Comments) {
                            Write-Verbose "Comment data found for $(Compress-ObjectName $IoC)"
                            Add-Member -InputObject $Result -NotePropertyName comments -NotePropertyValue $Comments
                        } # End $Comments null check

                    } elseif($Job.name -eq 'VariantsJob' -and $Job.State -eq "Completed") {
                        $Variants = Receive-Job -Job $Job -Wait
                        
                        # Check for variants
                        if($Null -ne $Variants) {
                            Write-Verbose "$(($Variants | Measure-Object).Count) variants found for $(Compress-ObjectName $IoC)"
                            Add-Member -InputObject $Result -NotePropertyName variants -NotePropertyValue $Variants
                        } # End $Variants null check

                    } # End $Job.name if statement

                } # End foreach $Jobs enumeration
                
                if([bool](($Results | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -match $(Compress-ObjectName $IoC))) {
                    continue    
                } else {
                    Write-Verbose "Adding resulting object for $(Compress-ObjectName $IoC) to the final results"
                    Add-Member -InputObject $Results -NotePropertyName $(Compress-ObjectName $IoC) -NotePropertyValue $Result
                    $TotalCount = $TotalCount + 1

                    # Add any asset that has a sighting AND a malEval HIGH or VERY_HIGH score or a MALICIOUS opinion to the $AffectedAssets array
                    if(($Result.malEval.probabilityBucket -eq "PROBABILITY_VERY_HIGH" -or $Result.malEval.probabilityBucket -eq "PROBABILITY_HIGH" -or $Result.malEval.severity -eq "HIGH" -or $Result.opinions.verdict -eq "MALICIOUS") -and ($Null -ne $Result.sightings)) {
                        foreach($Asset in $Result.sightings) {
                            $AffectedAssets += $Asset.assetName
                        }
                    }

                } # End duplicate check


                $VariantCount = 0
                # Of those variants are there any that have been seen in the current environment
                $Variants | ForEach-Object {
                    
                    # Check to see if we already have this variant, if so, skip it
                    if([bool](($Results | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -notmatch $(Compress-ObjectName $_.variant.sha256))) {
                    
                        # Check that this Variant is not null and has a similarity > $Threshold
                        if($Null -ne $_ -and ($_.similarity*100) -gt $Threshold) {
                            $VariantCount = $VariantCount + 1
                            $TotalCount = $TotalCount + 1
                            Write-Verbose "Analyzing $($VariantCount) of $(($Variants | Measure-Object).Count) Variants related to $(Compress-ObjectName $IoC)"
                            $SubIoC = $_.variant.sha256
                            $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock { Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId; $VariantSighting = Get-StairwellObjectSightings -ObjectId $using:SubIoc -ErrorAction SilentlyContinue; return $VariantSighting } -Name VariantsSightingJob
                            
                            Start-Sleep -Milliseconds 100
                            
                            while ((Get-Job -Name 'VariantsSightingJob' -IncludeChildJob | Where-Object {$_.State -eq "Running"}).Count -gt 0) {Start-Sleep -Milliseconds 100} 6>$null
                            # $Null = Get-Job -Name 'VariantsSightingJob' | Wait-Job
                            
                            foreach ($Job in $Jobs) {
                                if($Job.name -eq ('VariantsSightingJob') -and $Job.State -eq "Completed") {
                                    $VariantSighting = Receive-Job -Job $Job -Wait

                                } # End VariantSighting job name check

                            } # End $Jobs foreach enumeration
                            if($Null -ne $VariantSighting) {

                                # For any variants with a sighting, create a completely independent object and add it to the final results
                                $SubResult = $_.variant
                                $SubResultsha256 = $SubResult.sha256

                                $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock { Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId; $VariantOpinions = Get-StairwellObjectOpinions -ObjectId $using:SubResultsha256 -ErrorAction SilentlyContinue; return $VariantOpinions } -Name VariantsOpinionsJob

                                Start-Sleep -Milliseconds 100
                                while ((Get-Job -Name 'VariantsSightingJob' -IncludeChildJob | Where-Object {$_.State -eq "Running"}).Count -gt 0) {Start-Sleep -Milliseconds 100} 6>$null

                                foreach ($Job in $Jobs) {
                                    if($Job.name -eq ('VariantsOpinionsJob') -and $Job.State -eq "Completed") {
                                        $VariantOpinion = Receive-Job -Job $Job -Wait
    
                                    } # End VariantOpinion job name check
    
                                } # End $Jobs foreach enumeration


                                if(($SubResult.malEval.probabilityBucket -eq "PROBABILITY_VERY_HIGH" -or $SubResult.malEval.probabilityBucket -eq "PROBABILITY_HIGH" -or $SubResult.malEval.severity -eq "HIGH" -or $VariantOpinion.opinions.verdict -eq "MALICIOUS") -and ($Null -ne $VariantSighting.sightings)) {
                                    foreach($Asset in $VariantSighting.sightings) {
                                        $AffectedAssets += $Asset.assetName | Out-Null
                                    }
                                }
                                
                                if($Null -ne $SubResult) {
                                    Write-Verbose "A subvariant was discovered: $(Compress-ObjectName $SubResult.sha256)"
                                    Add-Member -InputObject $SubResult -NotePropertyName 'sightings' -NotePropertyValue $VariantSighting

                                    # Check to see if we haven't already added the current object to our final results
                                    if([bool]($Results.PSobject.Properties -match $(Compress-ObjectName $SubResult.sha256))) {
                                        continue    
                                    } else {
                                        $SightingCount = $SightingCount + 1
                                        Write-Verbose "Variant sighting for object: $(Compress-ObjectName $SubIoc)"
                                        Write-Verbose "Adding resulting object for $(Compress-ObjectName $SubIoc) to the final results"
                                        Add-Member -InputObject $Results -NotePropertyName $(Compress-ObjectName $SubResult.sha256) -NotePropertyValue $SubResult
                                    }

                                } # End $SubResult null check

                            } # End $VariantSighting null check
                            


                            if($Null -ne $SubIoC) {
                                $arrayToSearch = [System.Collections.ArrayList]@($SubIoc)
                                $SubIoC = $Null # We only use it once
                            } else {
                                $arrayToSearch = [System.Collections.ArrayList]@()
                            }
                            
                            $ResultsArray = [System.Collections.ArrayList]::new()
                            $newIoCs = [System.Collections.ArrayList]::new()
                            $sIoC = $Null

                            if($null -ne $arrayToSearch) {
                                $arrayToSearch.Clone() | ForEach-Object {
                                    if($null -ne $_) {
                                        $TotalCount = $TotalCount + 1
                                        if($_ -is [string] -and $_ -ne "") {
                                            $sIoC = $_
                                            
                                        } elseif ($_ -eq "") {
                                            Write-Verbose "Empty string received from recursive object, skipping."
                                            continue
                                        } else {
                                            Write-Verbose "Error: Received $($_.GetType()) from recursive object."
                                        }
                                    
                                    }
                                }        

                                
                                while($Depth -ne 0) {
                                    $Depth = $Depth - 1
                                    $Jobs += Start-ThreadJob -InitializationScript { Import-Module -Name /Users/jtwells/dev/ps-stairwell/StairwellPS/Stairwell.psm1 } -ScriptBlock {
                                        Set-StairwellConfig -ApiToken $using:apiToken -EnvironmentId $using:environmentId
                                        $SubVariants = Get-StairwellObjectVariants -ObjectId $using:sIoC -ErrorAction SilentlyContinue
                                        return $SubVariants
                                    } -Name SubVariantsSightingsJob
                                    
                                    Start-Sleep -Milliseconds 100 | Out-Null
                                        
                                    while ((Get-Job -Name 'SubVariantsSightingsJob' -IncludeChildJob | Where-Object {$_.State -eq "Running"}).Count -gt 0) {Start-Sleep -Milliseconds 100} 6>$Null
                                    # $Null = Get-Job -Name 'SubVariantsSightingsJob' | Wait-Job
                                    
                                        foreach ($Job in $Jobs) {
                                            if($Job.name -eq 'SubVariantsSightingsJob' -and $Job.State -eq "Completed") {
                                                $SubVariants = Receive-Job -Job $Job -Wait
                                                
                                            } # End check for VariantSighting job name
                                            
                                        } # End $Jobs foreach enumeration
                                        
                                        if($Null -ne $SubVariants) {
                                            $SubVariants | ForEach-Object {
                                                    
                                                if([bool](($Results | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -notmatch $(Compress-ObjectName $IoC))) {

                                                
                                                    if($Null -ne $_ -and ($_.similarity*100) -gt $Threshold) {
                                                        $TotalCount = $TotalCount + 1
                                                        
                                                        # Extract the objectId from the sha256
                                                        $SubIoC = $_.variant.sha256
                                                        
                                                        # Check for any sightings to reduce noise
                                                        $SubVariantSighting = Get-StairwellObjectSightings -ObjectId $SubIoc -ErrorAction SilentlyContinue

                                                        if($Null -ne $SubVariantSighting) {
                                                            $SightingCount = $SightingCount + $SubVariantSighting.Length
                                                            Write-Verbose "Variant Sighting discovered for $(Compress-ObjectName $SubIoC)"
                                                            $SubResult = $_.variant
                                                            $ResultsArray.Add($SubResult) | Out-Null
                                                            $newIoCs.Add($SubIoC) | Out-Null

                                                            if(($SubResult.malEval.probabilityBucket -eq "PROBABILITY_VERY_HIGH" -or $SubResult.malEval.probabilityBucket -eq "PROBABILITY_HIGH" -or $SubResult.malEval.severity -eq "HIGH") -and ($Null -ne $SubVariantSighting.sightings)) {
                                                                foreach($Asset in $SubVariantSighting.sightings) {
                                                                    $AffectedAssets += $Asset.assetName | Out-Null
                                                                }
                                                            }

                                                        }
                                                        
                                                    } # End null check and threshold evaluation

                                                } # End duplicate check

                                            } # End SubVariants | ForEach-Object

                                        } # End SubVariants null check
                                            
                                        
                                    
                                } # End while loop that decrements $Depth to 0 ($Depth = $RecursionDepth)

                                # Clear the search array
                                $arrayToSearch.Clear() | Out-Null
                                # Put the newly collected IoCs into the search array to be used again
                                $arrayToSearch = $newIoCs
                                # Clear the new IoCs array to be used again
                                $newIoCs.Clear() | Out-Null
                    
                            } # End check if $arrayToSearch is not null
                        

                            if ($null -ne $ResultsArray) {
                                $ResultsArray | ForEach-Object {
                                    if($Null -ne $_) {
                                        
                                        # Check to see if we haven't already added the current object
                                        if([bool](($Results | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -match "$(Compress-ObjectName $_.sha256)")) {
                                            continue    
                                        } else {
                                            Write-Verbose "Adding object: $(Compress-ObjectName $_.sha256) from recursive search to final results"
                                            Add-Member -InputObject $Results -NotePropertyName $(Compress-ObjectName $_.sha256) -NotePropertyValue $_

                                        } # End duplicate check

                                    } # End null check

                                } # End $ResultsArray | ForEach-Object enumeration

                            $ResultsArray.Clear() | Out-Null
                            } # End check if $ResultsArray is not null
                            
                        } # End null check and threshold evaluation for first $Variants enumeration

                    } # End duplicate check
                    
                } # End $Variants | ForEach-Object enumeration


            } else {
                Write-Verbose "No data found for $(Compress-ObjectName $IoC) (name has been shortened for display only)"
                continue
            } # End if Metadata block
            
            
            
        } # End foreach $Ioc in $ObjectIds block
        Write-Verbose ""
        Write-Verbose "######################################"
        Write-Verbose "          SUMMARY REPORT  "
        Write-Verbose "######################################"
        Write-Verbose ""
        Write-Verbose "Analysis completed of the provided $($ObjectIds.Count) IoCs, and their $($TotalCount - $ObjectIds.Count) variants."
        Write-Verbose "Number of related object sightings: $($SightingCount)"
        Write-Verbose "Affected assets: $($AffectedAssets | %{$_ + " "})"
        
        # Add the list of affected assets to the final output if any are present
        if($Null -ne $AffectedAssets) {
            Add-Member -InputObject $Results -NotePropertyName "AffectedAssets" -NotePropertyValue $AffectedAssets
        }
        
        return $Results
    
    } # End process block

} # End function block
