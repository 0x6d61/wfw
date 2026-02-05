#Requires -Version 5.1
#Requires -Modules Pester

<#
.SYNOPSIS
    Parse-AddressSpec 関数の単体テスト
#>

BeforeAll {
    # テスト対象の関数をロード
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $ModulePath = Join-Path $ProjectRoot "src\wfw\Private\Parse-AddressSpec.ps1"
    . $ModulePath
}

Describe "Parse-AddressSpec" {
    Context "正常系" {
        It "'any'を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "any"
            $result | Should -Be @("Any")
        }

        It "大文字の'ANY'を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "ANY"
            $result | Should -Be @("Any")
        }

        It "単一IPアドレスをパースできる" {
            $result = Parse-AddressSpec -AddressSpec "192.168.1.1"
            $result | Should -Be @("192.168.1.1")
        }

        It "CIDR表記をパースできる" {
            $result = Parse-AddressSpec -AddressSpec "10.0.0.0/8"
            $result | Should -Be @("10.0.0.0/8")
        }

        It "複数アドレスをパースできる" {
            $result = Parse-AddressSpec -AddressSpec "192.168.1.1,10.0.0.0/8"
            $result | Should -Be @("192.168.1.1", "10.0.0.0/8")
        }

        It "空白を含むアドレス指定を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "192.168.1.1, 10.0.0.0/8"
            $result | Should -Be @("192.168.1.1", "10.0.0.0/8")
        }

        It "特殊キーワード 'LocalSubnet' を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "LocalSubnet"
            $result | Should -Be @("LocalSubnet")
        }

        It "境界値（0.0.0.0）を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "0.0.0.0"
            $result | Should -Be @("0.0.0.0")
        }

        It "境界値（255.255.255.255）を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "255.255.255.255"
            $result | Should -Be @("255.255.255.255")
        }

        It "プレフィックス長32を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "192.168.1.1/32"
            $result | Should -Be @("192.168.1.1/32")
        }

        It "プレフィックス長0を処理できる" {
            $result = Parse-AddressSpec -AddressSpec "0.0.0.0/0"
            $result | Should -Be @("0.0.0.0/0")
        }
    }

    Context "異常系" {
        It "無効なIPアドレス（256.0.0.0）でエラーになる" {
            { Parse-AddressSpec -AddressSpec "256.0.0.0" } | Should -Throw "*無効なIPアドレス*"
        }

        It "無効なIPアドレス（オクテット不足）でエラーになる" {
            { Parse-AddressSpec -AddressSpec "192.168.1" } | Should -Throw "*無効なアドレス指定*"
        }

        It "無効なプレフィックス長（33）でエラーになる" {
            { Parse-AddressSpec -AddressSpec "192.168.1.0/33" } | Should -Throw "*無効なプレフィックス長*"
        }

        It "無効な文字列でエラーになる" {
            { Parse-AddressSpec -AddressSpec "invalid" } | Should -Throw "*無効なアドレス指定*"
        }
    }
}
