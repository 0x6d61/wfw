#Requires -Version 5.1
<#
.SYNOPSIS
    wfw - Windows Defender Firewall CLI ツール

.DESCRIPTION
    Windows Defender Firewall を ufw/iptables 風の短いコマンドで操作する CLI ツール。

.EXAMPLE
    .\wfw.ps1 status
    ファイアウォールの状態を表示

.EXAMPLE
    .\wfw.ps1 allow 443
    ポート443を許可（インバウンド/TCP）

.EXAMPLE
    .\wfw.ps1 ttl allow 8080 --ttl 10m
    10分間だけポート8080を開放
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

# スクリプトのディレクトリを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# モジュールをインポート
$ModulePath = Join-Path $ScriptDir "src\wfw\wfw.psd1"
if (-not (Test-Path $ModulePath)) {
    Write-Error "モジュールが見つかりません: $ModulePath"
    exit 1
}

Import-Module $ModulePath -Force

# メインコマンドを実行
try {
    Invoke-Wfw -Arguments $Arguments
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
