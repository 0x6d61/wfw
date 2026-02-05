#Requires -Version 5.1
<#
.SYNOPSIS
    TTL (temporary rule) operations

.DESCRIPTION
    Add, list, and reap temporary rules

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options
#>
function Invoke-WfwTtl {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{}
    )

    # TODO: Implement in phase 4
    Write-Host "Invoke-WfwTtl: Not implemented (planned for phase 4)" -ForegroundColor Yellow
}

Export-ModuleMember -Function Invoke-WfwTtl
