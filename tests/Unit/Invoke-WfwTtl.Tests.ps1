#Requires -Version 5.1
#Requires -Modules Pester

BeforeAll {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Write-Host "ProjectRoot: $ProjectRoot"
    $ModulePath = Join-Path $ProjectRoot "src\wfw\wfw.psd1"
    Import-Module $ModulePath -Force
}

Describe "Invoke-WfwTtl" {
    Context "Argument Parsing" {
        It "Parses 'add' subcommand" {
            $result = Invoke-WfwTtl -Arguments @("add", "allow", "80") -Options @{} -PassThru
            $result.SubCommand | Should -Be "add"
        }

        It "Parses --ttl option" {
            $result = Invoke-WfwTtl -Arguments @("add", "allow", "80", "--ttl", "1h") -Options @{} -PassThru
            $result.Ttl | Should -Be "1h"
        }
        
        It "Defaults TTL to 1h if not specified" {
             $result = Invoke-WfwTtl -Arguments @("add", "allow", "80") -Options @{} -PassThru
             $result.Ttl | Should -Be "1h"
        }
    }

    Context "Execution (Mocked)" {
        It "add: Calls Add-WfwRule and then sets Description" {
             InModuleScope "wfw" {
                Mock Add-WfwRule { 
                    return (@{ Success = $true; RuleId = "NewRule" } | ConvertTo-Json)
                }
                Mock Set-NetFirewallRule {}
                Mock Get-Date { return [DateTime]"2026-01-01 12:00:00" } 

                # 1 hour TTL
                Invoke-WfwTtl -Arguments @("add", "allow", "80", "--ttl", "1h") -Options @{ DryRun = $false }
                
                Should -Invoke Add-WfwRule -Times 1
                # Should set description with expiry info (2026-01-01 13:00:00)
                Should -Invoke Set-NetFirewallRule -Times 1 -ParameterFilter { 
                    $Description -match "EXP:2026-01-01T13:00:00" 
                }
            }
        }
        
        It "reap: Lists rules and removes expired ones" {
             InModuleScope "wfw" {
                $pastDate = "2020-01-01T00:00:00"
                $futureDate = "2030-01-01T00:00:00"
                
                Mock Get-NetFirewallRule {
                    return @(
                        [PSCustomObject]@{ Name="Rule1"; Description="EXP:$pastDate" },
                        [PSCustomObject]@{ Name="Rule2"; Description="FWCLI Rule" }, # No EXP
                        [PSCustomObject]@{ Name="Rule3"; Description="EXP:$futureDate" }
                    )
                }
                Mock Remove-NetFirewallRule {}
                Mock Get-Date { return [DateTime]"2026-01-01 12:00:00" }

                Invoke-WfwTtl -Arguments @("reap") -Options @{ DryRun = $false }
                
                # Rule1 should be removed
                Should -Invoke Remove-NetFirewallRule -Times 1 -ParameterFilter { $Name -eq "Rule1" }
                # Rule3 should NOT be removed
                Should -Invoke Remove-NetFirewallRule -Times 0 -ParameterFilter { $Name -eq "Rule3" }
            }
        }
    }
}
