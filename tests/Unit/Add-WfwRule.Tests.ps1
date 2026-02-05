#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Write-Host "ProjectRoot: $ProjectRoot"
    $ModulePath = Join-Path $ProjectRoot "src\wfw\wfw.psd1"
    Write-Host "ModulePath: $ModulePath"
    Write-Host "File Exists: $(Test-Path $ModulePath)"
    Import-Module $ModulePath -Force

    $ParsePortPath = Join-Path $ProjectRoot "src\wfw\Private\Parse-PortSpec.ps1"
    $ParseAddrPath = Join-Path $ProjectRoot "src\wfw\Private\Parse-AddressSpec.ps1"
    $FormatRulePath = Join-Path $ProjectRoot "src\wfw\Private\Format-RuleName.ps1"
    . $ParsePortPath
    . $ParseAddrPath
    . $FormatRulePath
}

Describe "Add-WfwRule" {
    Context "Argument Parsing" {
        It "Port only - parses correctly" {
            $result = Add-WfwRule -Arguments @("allow", "443") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.Action | Should -Be "allow"
            $result.LocalPort | Should -Be "443"
            $result.Protocol | Should -Be "tcp"
            $result.Direction | Should -Be "in"
        }

        It "Port/Protocol - parses correctly" {
            $result = Add-WfwRule -Arguments @("allow", "53/udp") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.LocalPort | Should -Be "53"
            $result.Protocol | Should -Be "udp"
        }

        It "Direction in/out - parses correctly" {
            $result = Add-WfwRule -Arguments @("block", "out", "80") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.Action | Should -Be "block"
            $result.Direction | Should -Be "out"
            $result.LocalPort | Should -Be "80"
        }

        It "--raddr option - sets remote address" {
            $result = Add-WfwRule -Arguments @("allow", "22", "--raddr", "10.0.0.0/8") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.RemoteAddress | Should -Be "10.0.0.0/8"
        }

        It "--laddr option - sets local address" {
            $result = Add-WfwRule -Arguments @("allow", "8080", "--laddr", "192.168.1.100") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.LocalAddress | Should -Be "192.168.1.100"
        }

        It "--name option - sets custom name" {
            $result = Add-WfwRule -Arguments @("allow", "443", "--name", "MyWebServer") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.DisplayName | Should -Be "MyWebServer"
        }
    }

    Context "Error Cases" {
        It "No action - throws error" {
            { Add-WfwRule -Arguments @("443") -Options @{ DryRun = $true } } | Should -Throw
        }

        It "Invalid action - throws error" {
            { Add-WfwRule -Arguments @("permit", "443") -Options @{ DryRun = $true } } | Should -Throw
        }

        It "No port - throws error" {
            { Add-WfwRule -Arguments @("allow") -Options @{ DryRun = $true } } | Should -Throw
        }
    }

    Context "DryRun Mode" {
        It "DryRun mode - does not create actual rule" {
            $result = Add-WfwRule -Arguments @("allow", "12345") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.DryRun | Should -Be $true
        }
    }
}
