#Requires -Version 5.1
<#
.SYNOPSIS
    Add firewall rule

.DESCRIPTION
    Add allow or block rule

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options

.PARAMETER PassThru
    Return parsed parameters (for testing)

.EXAMPLE
    Add-WfwRule -Arguments @("allow", "443")
    Allow port 443

.EXAMPLE
    Add-WfwRule -Arguments @("block", "out", "53/udp")
    Block outbound UDP 53
#>
function Add-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [switch]$PassThru
    )

    # Default values
    $ruleParams = @{
        Action        = $null
        Direction     = "in"
        Protocol      = "tcp"
        LocalPort     = $null
        RemoteAddress = "Any"
        LocalAddress  = "Any"
        DisplayName   = $null
        DryRun        = $Options.DryRun -eq $true
    }

    # Parse arguments
    $i = 0
    $positionalArgs = @()

    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]

        switch -Regex ($arg) {
            '^--raddr$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $ruleParams.RemoteAddress = $Arguments[$i]
                }
            }
            '^--laddr$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $ruleParams.LocalAddress = $Arguments[$i]
                }
            }
            '^--name$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $ruleParams.DisplayName = $Arguments[$i]
                }
            }
            '^--profile$' {
                $i++
                # Profile is handled in global options
            }
            default {
                $positionalArgs += $arg
            }
        }
        $i++
    }

    # Parse positional arguments
    # Pattern: <action> [direction] <port>[/protocol]
    if ($positionalArgs.Count -eq 0) {
        throw "Please specify action (allow or block)"
    }

    $argIndex = 0

    # Action
    $action = $positionalArgs[$argIndex].ToLower()
    if ($action -notin @("allow", "block")) {
        throw "Invalid action: $action (specify allow or block)"
    }
    $ruleParams.Action = $action
    $argIndex++

    if ($argIndex -ge $positionalArgs.Count) {
        throw "Please specify port"
    }

    # Direction (optional)
    $nextArg = $positionalArgs[$argIndex].ToLower()
    if ($nextArg -in @("in", "out")) {
        $ruleParams.Direction = $nextArg
        $argIndex++

        if ($argIndex -ge $positionalArgs.Count) {
            throw "Please specify port"
        }
    }

    # Port/Protocol
    $portSpec = $positionalArgs[$argIndex]
    if ($portSpec -match '^(.+)/(.+)$') {
        $ruleParams.LocalPort = $Matches[1]
        $ruleParams.Protocol = $Matches[2].ToLower()
    }
    else {
        $ruleParams.LocalPort = $portSpec
    }

    # Validate port
    $parsedPorts = Parse-PortSpec -PortSpec $ruleParams.LocalPort

    # Validate address
    if ($ruleParams.RemoteAddress -ne "Any") {
        $null = Parse-AddressSpec -AddressSpec $ruleParams.RemoteAddress
    }
    if ($ruleParams.LocalAddress -ne "Any") {
        $null = Parse-AddressSpec -AddressSpec $ruleParams.LocalAddress
    }

    # Generate rule name
    if (-not $ruleParams.DisplayName) {
        $ruleParams.DisplayName = Format-RuleName `
            -Action $ruleParams.Action `
            -Direction $ruleParams.Direction `
            -Protocol $ruleParams.Protocol `
            -LocalPort $ruleParams.LocalPort `
            -RemoteAddress $ruleParams.RemoteAddress
    }

    # PassThru mode (for testing)
    if ($PassThru) {
        return [PSCustomObject]$ruleParams
    }

    # DryRun mode
    if ($ruleParams.DryRun) {
        $output = @{
            Action  = "add"
            Rule    = $ruleParams
            Message = "Adding rule (DryRun)"
        }

        if ($Options.Json) {
            Write-Output ($output | ConvertTo-Json -Depth 5)
        }
        else {
            Write-Host "[DryRun] Adding the following rule:" -ForegroundColor Yellow
            Write-Host "  Name: $($ruleParams.DisplayName)"
            Write-Host "  Action: $($ruleParams.Action)"
            Write-Host "  Direction: $($ruleParams.Direction)"
            Write-Host "  Protocol: $($ruleParams.Protocol)"
            Write-Host "  Port: $($ruleParams.LocalPort)"
            Write-Host "  Remote Address: $($ruleParams.RemoteAddress)"
        }
        return
    }

    # Actual rule creation
    try {
        $netFwParams = @{
            DisplayName = $ruleParams.DisplayName
            Direction   = if ($ruleParams.Direction -eq "in") { "Inbound" } else { "Outbound" }
            Action      = if ($ruleParams.Action -eq "allow") { "Allow" } else { "Block" }
            Protocol    = $ruleParams.Protocol.ToUpper()
            LocalPort   = $parsedPorts
            Group       = $script:WfwGroupName
            Enabled     = "True"
        }

        if ($ruleParams.RemoteAddress -ne "Any") {
            $netFwParams.RemoteAddress = (Parse-AddressSpec -AddressSpec $ruleParams.RemoteAddress)
        }

        if ($ruleParams.LocalAddress -ne "Any") {
            $netFwParams.LocalAddress = (Parse-AddressSpec -AddressSpec $ruleParams.LocalAddress)
        }

        $rule = New-NetFirewallRule @netFwParams

        if ($Options.Json) {
            $output = @{
                Success = $true
                RuleId  = $rule.Name
                Name    = $ruleParams.DisplayName
            }
            Write-Output ($output | ConvertTo-Json)
        }
        else {
            Write-Host "Rule added: $($ruleParams.DisplayName)" -ForegroundColor Green
        }
    }
    catch {
        throw "Failed to create rule: $_"
    }
}

Export-ModuleMember -Function Add-WfwRule
