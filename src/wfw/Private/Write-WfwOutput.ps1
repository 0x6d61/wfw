#Requires -Version 5.1
<#
.SYNOPSIS
    出力を適切なフォーマットで書き出す

.DESCRIPTION
    --json, --quiet, --verbose オプションに応じて出力を制御する

.PARAMETER Data
    出力するデータ

.PARAMETER Options
    グローバルオプション

.PARAMETER Message
    テキストメッセージ（通常出力用）

.PARAMETER Level
    ログレベル（Info, Warning, Error, Verbose）
#>
function Write-WfwOutput {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object]$Data,

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [string]$Message,

        [Parameter()]
        [ValidateSet("Info", "Warning", "Error", "Verbose", "Success")]
        [string]$Level = "Info"
    )

    # Quietモードではエラー以外を抑制
    if ($Options.Quiet -and $Level -notin @("Error")) {
        return
    }

    # Verboseモードのメッセージ
    if ($Level -eq "Verbose" -and -not $Options.Verbose) {
        return
    }

    # JSON出力
    if ($Options.Json -and $Data) {
        $Data | ConvertTo-Json -Depth 10
        return
    }

    # テキスト出力
    if ($Message) {
        switch ($Level) {
            "Info" { Write-Host $Message }
            "Warning" { Write-Host $Message -ForegroundColor Yellow }
            "Error" { Write-Host $Message -ForegroundColor Red }
            "Verbose" { Write-Host $Message -ForegroundColor Gray }
            "Success" { Write-Host $Message -ForegroundColor Green }
        }
    }
}
