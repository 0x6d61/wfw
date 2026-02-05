#Requires -Version 5.1
#Requires -Modules Pester

<#
.SYNOPSIS
    Parse-PortSpec 関数の単体テスト
#>

BeforeAll {
    # テスト対象の関数をロード
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $ModulePath = Join-Path $ProjectRoot "src\wfw\Private\Parse-PortSpec.ps1"
    . $ModulePath
}

Describe "Parse-PortSpec" {
    Context "正常系" {
        It "単一ポートをパースできる" {
            $result = Parse-PortSpec -PortSpec "443"
            $result | Should -Be @("443")
        }

        It "複数ポートをパースできる" {
            $result = Parse-PortSpec -PortSpec "80,443"
            $result | Should -Be @("80", "443")
        }

        It "ポート範囲をパースできる" {
            $result = Parse-PortSpec -PortSpec "1-1024"
            $result | Should -Be @("1-1024")
        }

        It "複合指定をパースできる" {
            $result = Parse-PortSpec -PortSpec "80,443,10000-10100"
            $result | Should -Be @("80", "443", "10000-10100")
        }

        It "'any'を処理できる" {
            $result = Parse-PortSpec -PortSpec "any"
            $result | Should -Be @("Any")
        }

        It "大文字の'ANY'を処理できる" {
            $result = Parse-PortSpec -PortSpec "ANY"
            $result | Should -Be @("Any")
        }

        It "空白を含むポート指定を処理できる" {
            $result = Parse-PortSpec -PortSpec "80, 443, 8080"
            $result | Should -Be @("80", "443", "8080")
        }

        It "境界値（ポート1）を処理できる" {
            $result = Parse-PortSpec -PortSpec "1"
            $result | Should -Be @("1")
        }

        It "境界値（ポート65535）を処理できる" {
            $result = Parse-PortSpec -PortSpec "65535"
            $result | Should -Be @("65535")
        }
    }

    Context "異常系" {
        It "無効なポート番号（0）でエラーになる" {
            { Parse-PortSpec -PortSpec "0" } | Should -Throw "*無効なポート番号*"
        }

        It "無効なポート番号（65536）でエラーになる" {
            { Parse-PortSpec -PortSpec "65536" } | Should -Throw "*無効なポート番号*"
        }

        It "無効なポート範囲（開始>終了）でエラーになる" {
            { Parse-PortSpec -PortSpec "1024-1" } | Should -Throw "*無効なポート範囲*"
        }

        It "無効な文字列でエラーになる" {
            { Parse-PortSpec -PortSpec "abc" } | Should -Throw "*無効なポート指定*"
        }

        It "負のポート番号でエラーになる" {
            { Parse-PortSpec -PortSpec "-1" } | Should -Throw "*無効なポート指定*"
        }
    }
}
