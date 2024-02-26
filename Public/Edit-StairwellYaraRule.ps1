function Edit-StairwellYaraRule {
    [alias('SwEditRule')]
    <#
    .SYNOPSIS
    Edits a given Yara rule
    .DESCRIPTION
    This function allows the user to edit the status and/or the body of an existing Yara rule in their Stairwell environment
    .PARAMETER EnvironmentId
    Enter the Environment ID from your Stairwell environment See: https://docs.stairwell.com/docs/how-to-find-the-environment-id
    If no Environment Id is supplied,this function will attempt to use the Environment Id from the global config.
    .PARAMETER RuleBody
    The rule contents in string format
    .PARAMETER Name
    The resource name for the Yara rule
    .Parameter Status
    The rule activation status; either active OR disabled
    .PARAMETER Fields
    The list of fields to update permitted values are either or both [Status,RuleBody]
    .EXAMPLE
    Edit-StairwellYaraRule -EnvironmentId <EnvId> -Name MyExampleRule -RuleBody 'rule ExampleRule {strings: $my_text_string="google.com" $my_hex_string = { E2 34 A1 C8 23 FB } condition: $my_text_string or $my_hex_string}' -Fields @(RuleBody,Status) -Status Active
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,
        HelpMessage="Enter the EnvironmentId for the Stairwell environment where the Yara rule will be created.")]
        [ValidatePattern("\w{6}\-\w{6}\-\w{6}\-\w{8}")]
        [string]$EnvironmentId,
        
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the resource name of the rule you are creating.")]
        [string]$Name,

        [Parameter(Mandatory=$true,
        HelpMessage="Enter the rule body you are creating")]
        [string]$RuleBody,

        [Parameter(Mandatory=$true,
        HelpMessage="Enter the rule fields you are updating [Tags, RuleBody, Name]")]
        [ValidateSet("Status","RuleBody")]
        [string[]]$Fields,

        [Parameter(Mandatory=$false,
        HelpMessage="Enter the new status of the Yara rule")]
        [ValidateSet("active","disabled")]
        [string]$Status
    )
    
    begin {
        precheck
    }

    process {
        Write-Verbose "-------------------------------------------"
        Write-Verbose "Editing Yara Rule: $($Name)"
        
        # Determining what EnvironmentId to use
        if ($null -ne $EnvironmentId) {
            $EnvId = $EnvironmentId
        } else {
            $EnvId = $Script:EnvironmentId
        }
        Write-Verbose "Using $($EnvId) for the Environment Id"
        
        # What rule fields to update
        $Fields = $Fields -replace 'Status','status'
        $Fields = $Fields -replace 'RuleBody','definition'
        if ($Fields.Length -eq 2) {
            $Fields = $Fields -join '%2C'
            Write-Verbose "Fields requested to be changed: $($Fields[0]) and $(Fields[1])"
        } elseif ($Fields.Length -eq 1) {
            $Fields = $Fields[0]
            Write-Verbose "Fields requested to be changed: $($Fields[0])"
        } else {
            Write-Error "Error: fields can include either or both Status, RuleBody"
        }

        $Body = @{
            "name" = $Name
            "definition" = $RuleBody
        }
        Write-Verbose "Rule name supplied: $($Name)"
        Write-Verbose "Rule definition (rule body) supplied: $($RuleBody)"
        if ($null -ne $Status) {
            $Body.Add("status",$Status.ToLower())
            Write-Verbose "Status update supplied: $($Status)"
        }
        
        
        $Url = $script:baseUri + 'environments/' + $EnvId + '/yaraRules/' + $Name + '?updateMask=' + $Fields
        Write-Verbose "Using Url: $($Url)"
        

        $ReqParams = @{
            Uri = $Url
            Method = 'PATCH'
            Headers = $script:headers
            Body = $($Body | ConvertTo-Json)
            TimeoutSec = 60
            MaximumRetryCount = 5
            RetryIntervalSec = 1
        }

        try {
            $response = Invoke-WebRequest @ReqParams
            if ($response.StatusCode -eq 200) {
                $Content = $response.Content | ConvertFrom-Json
                Write-Verbose "Yara rule $($Name) updated successfully"
                return $Content
            } else {
                Write-Error -Message "Error; Response Code: $($response.StatusCode) $($response.StatusDescription)"
            }
        }
        catch {
            Write-Error -Message $($Error[0].Exception.Message)
        }

    }
}
