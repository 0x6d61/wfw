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
        [hashtable]$Options = @{}
    )

    # TODO: Implement in phase 3
    Write-Host "Get-WfwRule: Not implemented (planned for phase 3)" -ForegroundColor Yellow
}

Export-ModuleMember -Function Get-WfwRule
