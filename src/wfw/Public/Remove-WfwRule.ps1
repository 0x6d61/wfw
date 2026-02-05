#Requires -Version 5.1
<#
.SYNOPSIS
    ファイアウォールルールを削除

.DESCRIPTION
    指定したルールを削除する

.PARAMETER Arguments
    コマンド引数

.PARAMETER Options
    グローバルオプション
#>
function Remove-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{}
    )

    # TODO: フェーズ3で実装
    Write-Host "Remove-WfwRule: 未実装（フェーズ3で実装予定）" -ForegroundColor Yellow
}

Export-ModuleMember -Function Remove-WfwRule
