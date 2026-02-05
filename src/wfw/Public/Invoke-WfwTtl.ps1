#Requires -Version 5.1
<#
.SYNOPSIS
    TTL (temporary rule) operations

.DESCRIPTION
    Add temporary rule or reap expired rules.
    Rules are regular firewall rules with an expiration timestamp in the Description field.
    Format: EXP:<ISO8601-Timestamp>

.PARAMETER Arguments
    Command arguments. First argument is subcommand (add, reap, list).

.PARAMETER Options
    Global options

.PARAMETER PassThru
    Return parsed parameters (for testing)

.EXAMPLE
    Invoke-WfwTtl -Arguments @("add", "allow", "80", "--ttl", "1h")
    Add rule with 1 hour TTL

.EXAMPLE
    Invoke-WfwTtl -Arguments @("reap")
    Remove expired rules
#>
function Invoke-WfwTtl {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [switch]$PassThru
    )

    # Default params
    $params = @{
        SubCommand = "list"
        Ttl        = "1h"
        RuleArgs   = @()
    }

    if ($Arguments.Count -eq 0) {
        $params.SubCommand = "list"
    } else {
        $params.SubCommand = $Arguments[0].ToLower()
    }

    # Parse arguments
    $i = 1 # Skip subcommand
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]
        switch -Regex ($arg) {
            '^--ttl$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $params.Ttl = $Arguments[$i]
                }
            }
            default {
                $params.RuleArgs += $arg
            }
        }
        $i++
    }

    if ($PassThru) {
        return [PSCustomObject]$params
    }

    try {
        if ($params.SubCommand -eq "add") {
            # 1. Calc Expiry
            $now = Get-Date
            $expiry = $null
            
            if ($params.Ttl -match '^(\d+)([smhd])$') {
                $val = [int]$Matches[1]
                $unit = $Matches[2]
                switch ($unit) {
                    's' { $expiry = $now.AddSeconds($val) }
                    'm' { $expiry = $now.AddMinutes($val) }
                    'h' { $expiry = $now.AddHours($val) }
                    'd' { $expiry = $now.AddDays($val) }
                }
            } else {
                 throw "Invalid TTL format: $($params.Ttl). Use format like 1h, 30m, 1d."
            }
            
            $expiryStr = $expiry.ToString("yyyy-MM-ddTHH:mm:ss")
            $descTag = "EXP:$expiryStr"

            if ($Options.DryRun) {
                Write-Host "[DryRun] TTL Add: Expires at $expiryStr" -ForegroundColor Yellow
                # Delegate to Add-WfwRule for DryRun output of the rule itself
                Add-WfwRule -Arguments $params.RuleArgs -Options $Options
                return
            }

            # 2. Call Add-WfwRule
            # Capture output to get rule name/ID if possible. 
            # Add-WfwRule currently outputs text or JSON.
            # We need to run it with JSON to parse easily, or rely on Name flag if we passed it.
            # But Add-WfwRule generates name if not provided.
            
            # Let's force JSON mode locally for Add-WfwRule call to get the ID
            $addOptions = $Options.Clone()
            $addOptions.Json = $true
            
            # Suppress console output for internal call
            $resultJson = Add-WfwRule -Arguments $params.RuleArgs -Options $addOptions | Out-String
            $result = $resultJson | ConvertFrom-Json
            
            if (-not $result.Success) {
                throw "Failed to add rule."
            }
            
            $ruleName = $result.RuleId # or Name
            
            # 3. Update Description
            # First fetch existing description to append or overwrite?
            # Creating new rule, so overwrite is fine.
            Set-NetFirewallRule -Name $ruleName -Description $descTag -ErrorAction Stop
            
            if ($Options.Json) {
                $output = @{
                    Success = $true
                    RuleId = $ruleName
                    Expiry = $expiryStr
                }
                Write-Output ($output | ConvertTo-Json)
            } else {
                Write-Host "TTL Rule added: $ruleName (Expires: $expiryStr)" -ForegroundColor Green
            }

        }
        elseif ($params.SubCommand -eq "reap") {
            if ($Options.DryRun) {
                Write-Host "[DryRun] Reaping expired rules..." -ForegroundColor Yellow
            }

            $rules = Get-NetFirewallRule -Group $script:WfwGroupName -ErrorAction SilentlyContinue
            $now = Get-Date
            $count = 0

            foreach ($rule in $rules) {
                if ($rule.Description -match 'EXP:(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})') {
                    $expStr = $Matches[1]
                    try {
                        $expDate = [DateTime]::ParseExact($expStr, "yyyy-MM-ddTHH:mm:ss", $null)
                        
                        if ($now -gt $expDate) {
                            if ($Options.DryRun) {
                                Write-Host "[DryRun] Would remove expired rule: $($rule.Name) (Expired: $expStr)" -ForegroundColor Yellow
                            } else {
                                Remove-NetFirewallRule -Name $rule.Name -ErrorAction Stop
                                Write-Host "Reaped expired rule: $($rule.Name)" -ForegroundColor Green
                            }
                            $count++
                        }
                    }
                    catch {
                        Write-Warning "Failed to parse expiry for rule $($rule.Name): $expStr"
                    }
                }
            }
            
            if (-not $Options.Json -and -not $Options.DryRun) {
                Write-Host "Reaped $count rules."
            }
        }
        elseif ($params.SubCommand -eq "list") {
             # List only TTL rules
             $rules = Get-NetFirewallRule -Group $script:WfwGroupName -ErrorAction SilentlyContinue
             $ttlRules = @()
             
             foreach ($rule in $rules) {
                if ($rule.Description -match 'EXP:(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})') {
                    $ttlRules += @{
                        Name = $rule.Name
                        DisplayName = $rule.DisplayName
                        Expiry = $Matches[1]
                        Enabled = $rule.Enabled
                    }
                }
             }
             
             if ($Options.Json) {
                Write-Output ($ttlRules | ConvertTo-Json)
             } else {
                if ($ttlRules.Count -eq 0) {
                    Write-Host "No TTL rules found."
                } else {
                    $ttlRules | Format-Table Name, Expiry, Enabled -AutoSize | Out-String | Write-Host
                }
             }
        }
        else {
            throw "Unknown subcommand: $($params.SubCommand)"
        }
    }
    catch {
        throw "Failed to execute ttl $($params.SubCommand): $_"
    }
}

Export-ModuleMember -Function Invoke-WfwTtl
