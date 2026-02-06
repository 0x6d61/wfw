#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Write-Host "ProjectRoot: $ProjectRoot"
    $ModulePath = Join-Path $ProjectRoot "src\wfw\wfw.psd1"
    Import-Module $ModulePath -Force
}

Describe "Remove-WfwRule" {
    Context "Argument Parsing" {
        It "Parses ID correctly" {
            $result = Remove-WfwRule -Arguments @("1234") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.Id | Should -Be "1234"
        }

        It "Parses Name correctly (using --name)" {
            $result = Remove-WfwRule -Arguments @("--name", "MyRule") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.Name | Should -Be "MyRule"
        }
        
        It "Throws error if no ID or Name specified" {
            { Remove-WfwRule -Arguments @() -Options @{ DryRun = $true } } | Should -Throw
        }
    }

    Context "DryRun Mode" {
        It "DryRun mode - does not call Remove-NetFirewallRule" {
            Mock Remove-NetFirewallRule {}
            
            Remove-WfwRule -Arguments @("1234") -Options @{ DryRun = $true }
            
            Should -Invoke Remove-NetFirewallRule -Times 0
        }
    }

    Context "Execution" {
        It "Calls Remove-NetFirewallRule with correct ID" {
            InModuleScope "wfw" {
                Mock Remove-NetFirewallRule {}
                
                Remove-WfwRule -Arguments @("TestRule") -Options @{ DryRun = $false }
                
                Should -Invoke Remove-NetFirewallRule -Times 1 -ParameterFilter { $Name -eq "TestRule" }
            }
        }
    }
}
