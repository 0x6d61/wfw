#Requires -Version 5.1
<#
.SYNOPSIS
    TTL（一時ルール）機能

.DESCRIPTION
    一時的なルールの追加、一覧表示、期限切れ削除を行う

.PARAMETER Arguments
    コマンド引数

.PARAMETER Options
    グローバルオプション
#>
function Invoke-WfwTtl {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{}
    )

    # TODO: フェーズ4で実装
    Write-Host "Invoke-WfwTtl: 未実装（フェーズ4で実装予定）" -ForegroundColor Yellow
}

Export-ModuleMember -Function Invoke-WfwTtl
