#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Write-Host "ProjectRoot: $ProjectRoot"
    $ModulePath = Join-Path $ProjectRoot "src\wfw\wfw.psd1"
    Import-Module $ModulePath -Force
}

Describe "Set-WfwRule" {
    Context "Argument Parsing" {
        It "Parses ID correctly" {
            $result = Set-WfwRule -Action "enable" -Arguments @("1234") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.Action | Should -Be "enable"
            $result.Id | Should -Be "1234"
        }

        It "Parses Name correctly (using --name)" {
            $result = Set-WfwRule -Action "disable" -Arguments @("--name", "MyRule") -Options @{ DryRun = $true; Json = $true } -PassThru
            $result.Action | Should -Be "disable"
            $result.Name | Should -Be "MyRule"
        }
        
        It "Validates Action parameter" {
            { Set-WfwRule -Action "invalid" -Arguments @("123") -Options @{ DryRun = $true } } | Should -Throw
        }
    }

    Context "DryRun Mode" {
        It "DryRun mode - does not call Enable/Disable-NetFirewallRule" {
            InModuleScope "wfw" {
                Mock Enable-NetFirewallRule {}
                Mock Disable-NetFirewallRule {}
                
                Set-WfwRule -Action "enable" -Arguments @("1234") -Options @{ DryRun = $true }
                
                Should -Invoke Enable-NetFirewallRule -Times 0
            }
        }
    }
    
    Context "Execution (Mocked)" {
        It "Calls Enable-NetFirewallRule for enable action" {
             InModuleScope "wfw" {
                Mock Enable-NetFirewallRule {}
                
                Set-WfwRule -Action "enable" -Arguments @("TestRule") -Options @{ DryRun = $false }
                
                Should -Invoke Enable-NetFirewallRule -Times 1 -ParameterFilter { $Name -eq "TestRule" }
            }
        }

        It "Calls Disable-NetFirewallRule for disable action" {
             InModuleScope "wfw" {
                Mock Disable-NetFirewallRule {}
                
                Set-WfwRule -Action "disable" -Arguments @("TestRule") -Options @{ DryRun = $false }
                
                Should -Invoke Disable-NetFirewallRule -Times 1 -ParameterFilter { $Name -eq "TestRule" }
            }
        }

        It "Toggle action - Checks status and flips it (Mocking Get/Enable/Disable)" {
            InModuleScope "wfw" {
                # Mock Get-NetFirewallRule to return an enabled rule
                Mock Get-NetFirewallRule {
                    return [PSCustomObject]@{
                        Name = "TestRule"
                        Enabled = 1 # True (Enabled)
                    }
                }
                Mock Disable-NetFirewallRule {}
                Mock Enable-NetFirewallRule {}

                Set-WfwRule -Action "toggle" -Arguments @("TestRule") -Options @{ DryRun = $false }

                # Since it was enabled, it should be disabled
                Should -Invoke Disable-NetFirewallRule -Times 1
                Should -Invoke Enable-NetFirewallRule -Times 0
            }
        }
    }
}
