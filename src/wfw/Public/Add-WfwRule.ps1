#Requires -Version 5.1
<#
.SYNOPSIS
    ファイアウォールルールを追加

.DESCRIPTION
    allow または block のルールを追加する

.PARAMETER Arguments
    コマンド引数

.PARAMETER Options
    グローバルオプション
#>
function Add-WfwRule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Arguments = @(),

        [Parameter()]
        [hashtable]$Options = @{}
    )

    # TODO: フェーズ3で実装
    Write-Host "Add-WfwRule: 未実装（フェーズ3で実装予定）" -ForegroundColor Yellow
}

Export-ModuleMember -Function Add-WfwRule
