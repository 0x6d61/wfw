#Requires -Version 5.1
<#
.SYNOPSIS
    アドレス指定文字列をパースする

.DESCRIPTION
    アドレス指定文字列を配列に変換する
    対応形式: "any", "1.2.3.4", "10.0.0.0/8", "1.2.3.4,5.6.7.8,10.0.0.0/8"

.PARAMETER AddressSpec
    アドレス指定文字列

.OUTPUTS
    パースされたアドレス配列

.EXAMPLE
    Parse-AddressSpec -AddressSpec "any"
    # 出力: @("Any")

.EXAMPLE
    Parse-AddressSpec -AddressSpec "192.168.1.1"
    # 出力: @("192.168.1.1")

.EXAMPLE
    Parse-AddressSpec -AddressSpec "10.0.0.0/8,192.168.0.0/16"
    # 出力: @("10.0.0.0/8", "192.168.0.0/16")
#>
function Parse-AddressSpec {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AddressSpec
    )

    # 空文字列または "any" の場合
    if ([string]::IsNullOrWhiteSpace($AddressSpec) -or $AddressSpec.ToLower() -eq "any") {
        return @("Any")
    }

    # カンマで分割
    $parts = $AddressSpec -split ','

    $result = @()
    foreach ($part in $parts) {
        $part = $part.Trim()

        # CIDR表記（例: 10.0.0.0/8）の検証
        if ($part -match '^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/(\d{1,2})$') {
            $ip = $Matches[1]
            $prefix = [int]$Matches[2]

            # IPアドレスの検証
            if (-not (Test-IPv4Address -Address $ip)) {
                throw "無効なIPアドレス: $ip"
            }

            # プレフィックス長の検証
            if ($prefix -lt 0 -or $prefix -gt 32) {
                throw "無効なプレフィックス長: $prefix（0-32の範囲で指定してください）"
            }

            $result += $part
        }
        # 単一IPアドレス（例: 192.168.1.1）の検証
        elseif ($part -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
            if (-not (Test-IPv4Address -Address $part)) {
                throw "無効なIPアドレス: $part"
            }
            $result += $part
        }
        # 特殊キーワード
        elseif ($part.ToLower() -in @("localsubnet", "dns", "dhcp", "wins", "defaultgateway")) {
            $result += $part
        }
        else {
            throw "無効なアドレス指定: $part"
        }
    }

    return $result
}

<#
.SYNOPSIS
    IPv4アドレスを検証する

.PARAMETER Address
    検証するIPアドレス文字列

.OUTPUTS
    有効な場合は $true、無効な場合は $false
#>
function Test-IPv4Address {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Address
    )

    $octets = $Address -split '\.'
    if ($octets.Count -ne 4) {
        return $false
    }

    foreach ($octet in $octets) {
        $value = 0
        if (-not [int]::TryParse($octet, [ref]$value)) {
            return $false
        }
        if ($value -lt 0 -or $value -gt 255) {
            return $false
        }
    }

    return $true
}
