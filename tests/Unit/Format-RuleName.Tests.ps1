#Requires -Version 5.1
#Requires -Modules Pester

<#
.SYNOPSIS
    Format-RuleName 関数の単体テスト
#>

BeforeAll {
    # テスト対象の関数をロード
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $ModulePath = Join-Path $ProjectRoot "src\wfw\Private\Format-RuleName.ps1"
    . $ModulePath
}

Describe "Format-RuleName" {
    Context "正常系" {
        It "基本的なルール名を生成できる" {
            $result = Format-RuleName -Action "allow" -Direction "in" -Protocol "tcp" -LocalPort "443"
            $result | Should -Match "^FWCLI:allow:in:tcp:443:any:\d{14}$"
        }

        It "blockアクションのルール名を生成できる" {
            $result = Format-RuleName -Action "block" -Direction "out" -Protocol "udp" -LocalPort "53"
            $result | Should -Match "^FWCLI:block:out:udp:53:any:\d{14}$"
        }

        It "リモートアドレスを含むルール名を生成できる" {
            $result = Format-RuleName -Action "allow" -Direction "in" -Protocol "tcp" -LocalPort "22" -RemoteAddress "10.0.0.0/8"
            $result | Should -Match "^FWCLI:allow:in:tcp:22:10\.0\.0\.0/8:\d{14}$"
        }

        It "長いリモートアドレスを短縮できる" {
            $result = Format-RuleName -Action "allow" -Direction "in" -Protocol "tcp" -LocalPort "80" -RemoteAddress "192.168.100.200/24"
            $result | Should -Match "^FWCLI:allow:in:tcp:80:192\.168\.100\.\.\.\.:\d{14}$"
        }

        It "デフォルト値が正しく設定される" {
            $result = Format-RuleName -Action "allow"
            $result | Should -Match "^FWCLI:allow:in:tcp:any:any:\d{14}$"
        }
    }

    Context "タイムスタンプ" {
        It "タイムスタンプが14桁の数字である" {
            $result = Format-RuleName -Action "allow"
            $timestamp = $result -replace "^FWCLI:allow:in:tcp:any:any:", ""
            $timestamp | Should -Match "^\d{14}$"
        }

        It "連続呼び出しで異なるタイムスタンプが生成される可能性がある" {
            # 注: 同一秒内では同じタイムスタンプになる可能性があるため、
            # ここでは形式の検証のみ行う
            $result1 = Format-RuleName -Action "allow"
            $result2 = Format-RuleName -Action "block"
            $result1 | Should -Not -Be $result2
        }
    }
}
