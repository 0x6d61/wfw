#Requires -Version 5.1
<#
.SYNOPSIS
    Remove firewall rule

.DESCRIPTION
    Remove specified rule

.PARAMETER Arguments
    Command arguments

.PARAMETER Options
    Global options
#>
function Remove-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{}
    )

    # TODO: Implement in phase 3
    Write-Host "Remove-WfwRule: Not implemented (planned for phase 3)" -ForegroundColor Yellow
}

Export-ModuleMember -Function Remove-WfwRule
