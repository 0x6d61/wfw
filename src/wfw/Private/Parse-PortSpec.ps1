#Requires -Version 5.1
<#
.SYNOPSIS
    ポート指定文字列をパースする

.DESCRIPTION
    ポート指定文字列を配列に変換する
    対応形式: "443", "80,443", "1-1024", "80,443,10000-10100"

.PARAMETER PortSpec
    ポート指定文字列

.OUTPUTS
    パースされたポート配列または範囲文字列の配列

.EXAMPLE
    Parse-PortSpec -PortSpec "443"
    # 出力: @("443")

.EXAMPLE
    Parse-PortSpec -PortSpec "80,443"
    # 出力: @("80", "443")

.EXAMPLE
    Parse-PortSpec -PortSpec "1-1024"
    # 出力: @("1-1024")
#>
function Parse-PortSpec {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PortSpec
    )

    # 空文字列または "any" の場合
    if ([string]::IsNullOrWhiteSpace($PortSpec) -or $PortSpec.ToLower() -eq "any") {
        return @("Any")
    }

    # カンマで分割
    $parts = $PortSpec -split ','

    $result = @()
    foreach ($part in $parts) {
        $part = $part.Trim()

        # 範囲指定（例: 1-1024）の検証
        if ($part -match '^(\d+)-(\d+)$') {
            $start = [int]$Matches[1]
            $end = [int]$Matches[2]

            if ($start -lt 1 -or $start -gt 65535) {
                throw "無効なポート番号: $start（1-65535の範囲で指定してください）"
            }
            if ($end -lt 1 -or $end -gt 65535) {
                throw "無効なポート番号: $end（1-65535の範囲で指定してください）"
            }
            if ($start -ge $end) {
                throw "無効なポート範囲: $part（開始ポートは終了ポートより小さい必要があります）"
            }

            $result += $part
        }
        # 単一ポートの検証
        elseif ($part -match '^\d+$') {
            $port = [int]$part
            if ($port -lt 1 -or $port -gt 65535) {
                throw "無効なポート番号: $port（1-65535の範囲で指定してください）"
            }
            $result += $part
        }
        else {
            throw "無効なポート指定: $part"
        }
    }

    return $result
}
