#Requires -Version 5.1
<#
.SYNOPSIS
    Display rule list or details

.DESCRIPTION
    list: Show filtered rule list
    show: Show specific rule details

.PARAMETER SubCommand
    "list" or "show"

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options

.PARAMETER PassThru
    Return parsed parameters (for testing)
#>
function Get-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("list", "show")]
        [string]$SubCommand,

        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [switch]$PassThru
    )

    $params = @{
        SubCommand = $SubCommand
        Id         = $null
        Name       = $null
    }

    # Parse arguments
    $i = 0
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]
        switch -Regex ($arg) {
            '^--name$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $params.Name = $Arguments[$i]
                }
            }
            default {
                if (-not $params.Id) {
                    $params.Id = $arg
                }
            }
        }
        $i++
    }

    if ($SubCommand -eq "show" -and -not $params.Id -and -not $params.Name) {
        throw "Please specify rule ID or Name"
    }

    if ($PassThru) {
        return [PSCustomObject]$params
    }

    # Execute
    try {
        if ($SubCommand -eq "list") {
            # List rules
            $rules = Get-NetFirewallRule -Group $script:WfwGroupName -ErrorAction SilentlyContinue
            
            if (-not $rules) {
                if ($Options.Json) { Write-Output "[]" }
                else { Write-Host "No rules found." -ForegroundColor Yellow }
                return
            }

            if ($Options.Json) {
                $outputRules = @()
                foreach ($r in $rules) {
                    # Get port/address filter info is expensive, we might need Get-NetFirewallPortFilter etc.
                    # For performance, maybe just basic info first, or deep fetch.
                    # Let's keep it simple for now or fetch associated objects.
                    
                    $outputRules += @{
                        Name = $r.Name
                        DisplayName = $r.DisplayName
                        Enabled = $r.Enabled
                        Direction = $r.Direction
                        Action = $r.Action
                    }
                }
                Write-Output ($outputRules | ConvertTo-Json)
            } else {
                # Simple table output
                $rules | Format-Table -Property Name, DisplayName, Enabled, Direction, Action -AutoSize | Out-String | Write-Host
            }
        }
        elseif ($SubCommand -eq "show") {
            $targetName = if ($params.Name) { $params.Name } else { $params.Id }
            
            $rule = Get-NetFirewallRule -Name $targetName -ErrorAction Stop
            
            # Fetch details
            $portFilter = $rule | Get-NetFirewallPortFilter
            $addrFilter = $rule | Get-NetFirewallAddressFilter
            
            $ruleData = @{
                Name          = $rule.Name
                DisplayName   = $rule.DisplayName
                Description   = $rule.Description
                Enabled       = $rule.Enabled
                Direction     = $rule.Direction
                Action        = $rule.Action
                Protocol      = $portFilter.Protocol
                LocalPort     = $portFilter.LocalPort
                RemotePort    = $portFilter.RemotePort
                LocalAddress  = $addrFilter.LocalAddress
                RemoteAddress = $addrFilter.RemoteAddress
            }

            if ($Options.Json) {
                Write-Output ($ruleData | ConvertTo-Json)
            } else {
                Write-Host "Rule Details:" -ForegroundColor Cyan
                $ruleData.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize -HideTableHeaders | Out-String | Write-Host
            }
        }
    }
    catch {
        throw "Failed to execute ${SubCommand}: $_"
    }
}

Export-ModuleMember -Function Get-WfwRule
