#Requires -Version 5.1
<#
.SYNOPSIS
    ルール一覧・詳細を表示

.DESCRIPTION
    list: フィルタ付きルール一覧を表示
    show: 特定ルールの詳細を表示

.PARAMETER SubCommand
    "list" または "show"

.PARAMETER Arguments
    コマンド引数

.PARAMETER Options
    グローバルオプション
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

    # TODO: フェーズ3で実装
    Write-Host "Get-WfwRule: 未実装（フェーズ3で実装予定）" -ForegroundColor Yellow
}

Export-ModuleMember -Function Get-WfwRule
