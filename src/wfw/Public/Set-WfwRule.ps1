#Requires -Version 5.1
<#
.SYNOPSIS
    Enable, Disable, or Toggle firewall rule

.DESCRIPTION
    Change rule status by Name or ID

.PARAMETER Action
    enable, disable, or toggle

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options

.PARAMETER PassThru
    Return parsed parameters (for testing)

.EXAMPLE
    Set-WfwRule -Action "enable" -Arguments @("FWCLI:...")
    Enable rule
#>
function Set-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("enable", "disable", "toggle")]
        [string]$Action,

        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [switch]$PassThru
    )

    $ruleParams = @{
        Action = $Action
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

    if (-not $ruleParams.Id -and -not $ruleParams.Name) {
        throw "Please specify rule ID or Name"
    }

    $targetName = if ($ruleParams.Name) { $ruleParams.Name } else { $ruleParams.Id }

    if ($PassThru) {
        return [PSCustomObject]$ruleParams
    }

    if ($ruleParams.DryRun) {
        if ($Options.Json) {
            $output = @{
                Action = $Action
                Target = $targetName
                Message = "Setting rule status (DryRun)"
            }
            Write-Output ($output | ConvertTo-Json)
        } else {
            Write-Host "[DryRun] $Action rule: $targetName" -ForegroundColor Yellow
        }
        return
    }

    try {
        switch ($Action) {
            "enable" {
                Enable-NetFirewallRule -Name $targetName -ErrorAction Stop
                $msg = "Rule enabled"
            }
            "disable" {
                Disable-NetFirewallRule -Name $targetName -ErrorAction Stop
                $msg = "Rule disabled"
            }
            "toggle" {
                $rule = Get-NetFirewallRule -Name $targetName -ErrorAction Stop
                if ($rule.Enabled -eq "True" -or $rule.Enabled -eq 1 -or $rule.Enabled -eq $true) {
                    Disable-NetFirewallRule -Name $targetName -ErrorAction Stop
                    $msg = "Rule disabled (toggled)"
                } else {
                    Enable-NetFirewallRule -Name $targetName -ErrorAction Stop
                    $msg = "Rule enabled (toggled)"
                }
            }
        }

        if ($Options.Json) {
             $output = @{
                Success = $true
                Target = $targetName
                Action = $Action
            }
            Write-Output ($output | ConvertTo-Json)
        } else {
            Write-Host "${msg}: $targetName" -ForegroundColor Green
        }
    }
    catch {
        throw "Failed to $Action rule '$targetName': $_"
    }
}

Export-ModuleMember -Function Set-WfwRule
