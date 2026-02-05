#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Write-Host "ProjectRoot: $ProjectRoot"
    $ModulePath = Join-Path $ProjectRoot "src\wfw\wfw.psd1"
    Import-Module $ModulePath -Force
}

Describe "Get-WfwRule" {
    Context "List Command" {
        It "PassThru returns correct parameters for list" {
            $result = Get-WfwRule -SubCommand "list" -Arguments @("--verbose") -Options @{ Json = $true } -PassThru
            $result.SubCommand | Should -Be "list"
        }
        
        It "Executes Get-NetFirewallRule with correct group" {
            InModuleScope "wfw" {
                Mock Get-NetFirewallRule { return @() }
                
                Get-WfwRule -SubCommand "list" -Arguments @() -Options @{}
                
                # Should filter by Group = WfwGroupName (FWCLI)
                # Note: WfwGroupName is script scoped variable in module
                Should -Invoke Get-NetFirewallRule -Times 1 -ParameterFilter { $Group -eq "FWCLI" }
            }
        }
    }

    Context "Show Command" {
        It "PassThru returns correct ID for show" {
            $result = Get-WfwRule -SubCommand "show" -Arguments @("1234") -Options @{} -PassThru
            $result.Id | Should -Be "1234"
        }

        It "Parses --name argument" {
            $result = Get-WfwRule -SubCommand "show" -Arguments @("--name", "MyRule") -Options @{} -PassThru
            $result.Name | Should -Be "MyRule"
        }

        It "Throws if ID/Name missing for show" {
            { Get-WfwRule -SubCommand "show" -Arguments @() -Options @{} } | Should -Throw
        }

        It "Executes Get-NetFirewallRule with Name" {
            InModuleScope "wfw" {
                Mock Get-NetFirewallRule { 
                    return [PSCustomObject]@{
                        Name = "TestRule"
                        DisplayName = "Test Rule Display"
                        Enabled = 1
                        Direction = 1
                        Action = 2
                        Profile = 1
                        Group = "FWCLI"
                    }
                }
                
                Get-WfwRule -SubCommand "show" -Arguments @("TestRule") -Options @{}
                
                Should -Invoke Get-NetFirewallRule -Times 1 -ParameterFilter { $Name -eq "TestRule" }
            }
        }
    }
}
