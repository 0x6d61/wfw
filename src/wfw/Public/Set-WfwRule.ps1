#Requires -Version 5.1
<#
.SYNOPSIS
    Enable/Disable firewall rule

.DESCRIPTION
    Enable, disable, or toggle a rule

.PARAMETER Action
    "enable", "disable", or "toggle"

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options
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
        [hashtable]$Options = @{}
    )

    # TODO: Implement in phase 3
    Write-Host "Set-WfwRule: Not implemented (planned for phase 3)" -ForegroundColor Yellow
}

Export-ModuleMember -Function Set-WfwRule
