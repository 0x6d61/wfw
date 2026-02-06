#Requires -Version 5.1
<#
.SYNOPSIS
    wfw command main entry point

.DESCRIPTION
    Parse arguments and dispatch to subcommands

.PARAMETER Arguments
    Command line arguments array

.EXAMPLE
    Invoke-Wfw -Arguments @("status")
    Display firewall status

.EXAMPLE
    Invoke-Wfw -Arguments @("allow", "443")
    Allow port 443
#>
function Invoke-Wfw {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    # Show help if no arguments
    if (-not $Arguments -or $Arguments.Count -eq 0) {
        Show-WfwHelp
        return
    }

    # Extract global options
    $globalOptions = @{
        Json    = $false
        Quiet   = $false
        Verbose = $false
        DryRun  = $false
        Profile = "any"
    }

    $remainingArgs = @()
    $i = 0
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]
        switch -Regex ($arg) {
            '^--json$' { $globalOptions.Json = $true }
            '^--quiet$' { $globalOptions.Quiet = $true }
            '^--verbose$' { $globalOptions.Verbose = $true }
            '^--dry-run$' { $globalOptions.DryRun = $true }
            '^--profile$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $globalOptions.Profile = $Arguments[$i]
                }
            }
            default { $remainingArgs += $arg }
        }
        $i++
    }

    # Get subcommand
    if ($remainingArgs.Count -eq 0) {
        Show-WfwHelp
        return
    }

    $subCommand = $remainingArgs[0].ToLower()
    $subArgs = if ($remainingArgs.Count -gt 1) { $remainingArgs[1..($remainingArgs.Count - 1)] } else { @() }

    # Dispatch to subcommand
    switch ($subCommand) {
        "status" {
            Get-WfwStatus -Options $globalOptions
        }
        "list" {
            Get-WfwRule -SubCommand "list" -Arguments $subArgs -Options $globalOptions
        }
        "show" {
            Get-WfwRule -SubCommand "show" -Arguments $subArgs -Options $globalOptions
        }
        "add" {
            Add-WfwRule -Arguments $subArgs -Options $globalOptions
        }
        "allow" {
            # Shorthand: allow -> add allow
            Add-WfwRule -Arguments (@("allow") + $subArgs) -Options $globalOptions
        }
        "block" {
            # Shorthand: block -> add block
            Add-WfwRule -Arguments (@("block") + $subArgs) -Options $globalOptions
        }
        "del" {
            Remove-WfwRule -Arguments $subArgs -Options $globalOptions
        }
        "delete" {
            Remove-WfwRule -Arguments $subArgs -Options $globalOptions
        }
        "enable" {
            Set-WfwRule -Action "enable" -Arguments $subArgs -Options $globalOptions
        }
        "disable" {
            Set-WfwRule -Action "disable" -Arguments $subArgs -Options $globalOptions
        }
        "toggle" {
            Set-WfwRule -Action "toggle" -Arguments $subArgs -Options $globalOptions
        }
        "ttl" {
            Invoke-WfwTtl -Arguments $subArgs -Options $globalOptions
        }
        "help" {
            Show-WfwHelp
        }
        "--help" {
            Show-WfwHelp
        }
        "-h" {
            Show-WfwHelp
        }
        "version" {
            Write-Host "wfw version $script:WfwVersion"
        }
        "--version" {
            Write-Host "wfw version $script:WfwVersion"
        }
        "-v" {
            Write-Host "wfw version $script:WfwVersion"
        }
        default {
            Write-Error "Unknown command: $subCommand"
            Write-Host "Available commands: status, list, show, add, allow, block, del, enable, disable, toggle, ttl, help"
            exit $script:ExitCodes.ArgumentError
        }
    }
}

<#
.SYNOPSIS
    Display help message
#>
function Show-WfwHelp {
    $help = @"
wfw - Windows Defender Firewall CLI tool

Usage:
    wfw <command> [options]

Commands:
    status              Show firewall status
    list                List rules
    show <id|name>      Show rule details
    add allow|block     Add rule
    allow <port>        Allow port (shorthand for add allow)
    block <port>        Block port (shorthand for add block)
    del <id|name>       Delete rule
    enable <id|name>    Enable rule
    disable <id|name>   Disable rule
    toggle <id|name>    Toggle rule enabled/disabled
    ttl <subcommand>    Temporary rule operations
    help                Show this help
    version             Show version

Global Options:
    --json              Output in JSON format
    --quiet             Minimal output
    --verbose           Verbose logging
    --dry-run           Show plan without executing
    --profile <name>    Target profile (domain|private|public|any)

Examples:
    wfw status
    wfw allow 443
    wfw allow out 53/udp
    wfw block 3389 --raddr 0.0.0.0/0
    wfw ttl allow 8080 --ttl 10m
    wfw list --json
"@
    Write-Host $help
}

Export-ModuleMember -Function Invoke-Wfw
