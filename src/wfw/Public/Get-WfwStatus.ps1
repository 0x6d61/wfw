#Requires -Version 5.1
<#
.SYNOPSIS
    ファイアウォールの状態を表示

.DESCRIPTION
    各プロファイル（Domain, Private, Public）のファイアウォール状態を表示する

.PARAMETER Options
    グローバルオプション
#>
function Get-WfwStatus {
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]$Options = @{}
    )

    try {
        # NetSecurityモジュールの確認
        if (-not (Get-Module -ListAvailable -Name NetSecurity)) {
            Write-Error "NetSecurityモジュールが利用できません"
            exit $script:ExitCodes.GeneralError
        }

        # プロファイルごとの状態を取得
        $profiles = Get-NetFirewallProfile -ErrorAction Stop

        if ($Options.Json) {
            # JSON出力
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
            # テーブル出力
            if (-not $Options.Quiet) {
                Write-Host ""
                Write-Host "Windows Defender Firewall 状態" -ForegroundColor Cyan
                Write-Host "================================" -ForegroundColor Cyan
                Write-Host ""
            }

            foreach ($profile in $profiles) {
                $statusColor = if ($profile.Enabled) { "Green" } else { "Red" }
                $statusText = if ($profile.Enabled) { "有効" } else { "無効" }

                $inboundColor = if ($profile.DefaultInboundAction -eq "Block") { "Yellow" } else { "Green" }
                $outboundColor = if ($profile.DefaultOutboundAction -eq "Block") { "Yellow" } else { "Green" }

                Write-Host "$($profile.Name):" -ForegroundColor White -NoNewline
                Write-Host " $statusText" -ForegroundColor $statusColor

                if (-not $Options.Quiet) {
                    Write-Host "  インバウンド既定: " -NoNewline
                    Write-Host "$($profile.DefaultInboundAction)" -ForegroundColor $inboundColor
                    Write-Host "  アウトバウンド既定: " -NoNewline
                    Write-Host "$($profile.DefaultOutboundAction)" -ForegroundColor $outboundColor
                    Write-Host ""
                }
            }

            # FWCLI管理下のルール数を表示
            if (-not $Options.Quiet) {
                try {
                    $fwcliRules = Get-NetFirewallRule -Group $script:WfwGroupName -ErrorAction SilentlyContinue
                    $ruleCount = if ($fwcliRules) { @($fwcliRules).Count } else { 0 }
                    Write-Host "FWCLI管理下のルール: $ruleCount 件" -ForegroundColor Gray
                }
                catch {
                    # グループが存在しない場合は無視
                }
            }
        }
    }
    catch {
        Write-Error "ファイアウォール状態の取得に失敗しました: $_"
        exit $script:ExitCodes.GeneralError
    }
}

Export-ModuleMember -Function Get-WfwStatus
