#Requires -Version 5.1
<#
.SYNOPSIS
    wfw モジュールのメインファイル

.DESCRIPTION
    Public/Private フォルダの関数をドットソースでロードする
#>

# モジュールのルートディレクトリ
$ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Private関数をロード
$PrivatePath = Join-Path $ModuleRoot "Private"
if (Test-Path $PrivatePath) {
    Get-ChildItem -Path $PrivatePath -Filter "*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}

# Public関数をロード
$PublicPath = Join-Path $ModuleRoot "Public"
if (Test-Path $PublicPath) {
    Get-ChildItem -Path $PublicPath -Filter "*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}

# モジュール共通の定数
$script:WfwGroupName = "FWCLI"
$script:WfwVersion = "0.1.0"

# 終了コード定数
$script:ExitCodes = @{
    Success          = 0
    GeneralError     = 1
    ArgumentError    = 2
    PermissionDenied = 3
    NotFound         = 4
    Conflict         = 5
}
