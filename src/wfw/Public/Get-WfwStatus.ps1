#Requires -Version 5.1
<#
.SYNOPSIS
    Display firewall status

.DESCRIPTION
    Show firewall status for each profile (Domain, Private, Public)

.PARAMETER Options
    Global options
#>
function Get-WfwStatus {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Options = @{}
    )

    try {
        # Check NetSecurity module
        if (-not (Get-Module -ListAvailable -Name NetSecurity)) {
            Write-Error "NetSecurity module is not available"
            exit $script:ExitCodes.GeneralError
        }

        # Get profile status
        $profiles = Get-NetFirewallProfile -ErrorAction Stop

        if ($Options.Json) {
            # JSON output
            $result = @{
                profiles = @()
            }
            foreach ($profile in $profiles) {
                $result.profiles += @{
                    name                  = $profile.Name
                    enabled               = $profile.Enabled
                    defaultInboundAction  = $profile.DefaultInboundAction.ToString()
                    defaultOutboundAction = $profile.DefaultOutboundAction.ToString()
                    logAllowed            = $profile.LogAllowed
                    logBlocked            = $profile.LogBlocked
                    logFileName           = $profile.LogFileName
                }
            }
            $result | ConvertTo-Json -Depth 3
        }
        else {
            # Table output
            if (-not $Options.Quiet) {
                Write-Host ""
                Write-Host "Windows Defender Firewall Status" -ForegroundColor Cyan
                Write-Host "================================" -ForegroundColor Cyan
                Write-Host ""
            }

            foreach ($profile in $profiles) {
                $statusColor = if ($profile.Enabled) { "Green" } else { "Red" }
                $statusText = if ($profile.Enabled) { "Enabled" } else { "Disabled" }

                $inboundColor = if ($profile.DefaultInboundAction -eq "Block") { "Yellow" } else { "Green" }
                $outboundColor = if ($profile.DefaultOutboundAction -eq "Block") { "Yellow" } else { "Green" }

                Write-Host "$($profile.Name):" -ForegroundColor White -NoNewline
                Write-Host " $statusText" -ForegroundColor $statusColor

                if (-not $Options.Quiet) {
                    Write-Host "  Inbound Default: " -NoNewline
                    Write-Host "$($profile.DefaultInboundAction)" -ForegroundColor $inboundColor
                    Write-Host "  Outbound Default: " -NoNewline
                    Write-Host "$($profile.DefaultOutboundAction)" -ForegroundColor $outboundColor
                    Write-Host ""
                }
            }

            # Show FWCLI managed rule count
            if (-not $Options.Quiet) {
                try {
                    $fwcliRules = Get-NetFirewallRule -Group $script:WfwGroupName -ErrorAction SilentlyContinue
                    $ruleCount = if ($fwcliRules) { @($fwcliRules).Count } else { 0 }
                    Write-Host "FWCLI managed rules: $ruleCount" -ForegroundColor Gray
                }
                catch {
                    # Ignore if group does not exist
                }
            }
        }
    }
    catch {
        Write-Error "Failed to get firewall status: $_"
        exit $script:ExitCodes.GeneralError
    }
}

Export-ModuleMember -Function Get-WfwStatus
