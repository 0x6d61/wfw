#Requires -Version 5.1
<#
.SYNOPSIS
    Remove firewall rule

.DESCRIPTION
    Remove specified rule by Name or ID

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options

.PARAMETER PassThru
    Return parsed parameters (for testing)

.EXAMPLE
    Remove-WfwRule -Arguments @("FWCLI:...")
    Remove rule by ID
#>
function Remove-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [switch]$PassThru
    )

    $ruleParams = @{
        Id     = $null
        Name   = $null
        DryRun = $Options.DryRun -eq $true
    }

    # Parse arguments
    $i = 0
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]
        
        switch -Regex ($arg) {
            '^--name$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $ruleParams.Name = $Arguments[$i]
                }
            }
            default {
                if (-not $ruleParams.Id) {
                    $ruleParams.Id = $arg
                }
            }
        }
        $i++
    }

    # Prioritize Name over ID if both provided (though usually one is enough)
    # Actually, let's treat positional arg as ID/Name.
    if (-not $ruleParams.Id -and -not $ruleParams.Name) {
        throw "Please specify rule ID or Name"
    }

    # Target identifier
    $targetName = if ($ruleParams.Name) { $ruleParams.Name } else { $ruleParams.Id }
    
    # Update params for PassThru (consolidate to Name/Id logic if needed)
    # For testing consistency with test script:
    if ($ruleParams.Name) { 
        # Test expects .Name
    } else {
        # Test expects .Id
    }

    if ($PassThru) {
        return [PSCustomObject]$ruleParams
    }

    if ($ruleParams.DryRun) {
        if ($Options.Json) {
            $output = @{
                Action = "delete"
                Target = $targetName
                Message = "Removing rule (DryRun)"
            }
            Write-Output ($output | ConvertTo-Json)
        } else {
            Write-Host "[DryRun] Removing rule: $targetName" -ForegroundColor Yellow
        }
        return
    }

    try {
        # Try to remove by Name first (ID is often Name in NetFirewallRule)
        # We use Remove-NetFirewallRule. It accepts piped input or -Name or -DisplayName.
        # Since our IDs are likely Names (FWCLI:...), we use -Name.
        # If user provides DisplayName, we might need lookup logic, but for now let's stick to Name/ID.
        
        Remove-NetFirewallRule -Name $targetName -ErrorAction Stop
        
        if ($Options.Json) {
             $output = @{
                Success = $true
                Target = $targetName
            }
            Write-Output ($output | ConvertTo-Json)
        } else {
            Write-Host "Rule removed: $targetName" -ForegroundColor Green
        }
    }
    catch {
        throw "Failed to remove rule '$targetName': $_"
    }
}

Export-ModuleMember -Function Remove-WfwRule
