#Requires -Version 5.1
<#
.SYNOPSIS
    wfw コマンドのメインエントリポイント

.DESCRIPTION
    引数を解析してサブコマンドにディスパッチする

.PARAMETER Arguments
    コマンドライン引数の配列

.EXAMPLE
    Invoke-Wfw -Arguments @("status")
    ファイアウォールの状態を表示

.EXAMPLE
    Invoke-Wfw -Arguments @("allow", "443")
    ポート443を許可
#>
function Invoke-Wfw {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$Arguments
    )

    # 引数がない場合はヘルプを表示
    if (-not $Arguments -or $Arguments.Count -eq 0) {
        Show-WfwHelp
        return
    }

    # グローバルオプションを抽出
    $globalOptions = @{
        Json    = $false
        Quiet   = $false
        Verbose = $false
        DryRun  = $false
        Profile = "any"
    }

    $remainingArgs = @()
    $i = 0
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]
        switch -Regex ($arg) {
            '^--json$' { $globalOptions.Json = $true }
            '^--quiet$' { $globalOptions.Quiet = $true }
            '^--verbose$' { $globalOptions.Verbose = $true }
            '^--dry-run$' { $globalOptions.DryRun = $true }
            '^--profile$' {
                $i++
                if ($i -lt $Arguments.Count) {
                    $globalOptions.Profile = $Arguments[$i]
                }
            }
            default { $remainingArgs += $arg }
        }
        $i++
    }

    # サブコマンドを取得
    if ($remainingArgs.Count -eq 0) {
        Show-WfwHelp
        return
    }

    $subCommand = $remainingArgs[0].ToLower()
    $subArgs = if ($remainingArgs.Count -gt 1) { $remainingArgs[1..($remainingArgs.Count - 1)] } else { @() }

    # サブコマンドにディスパッチ
    switch ($subCommand) {
        "status" {
            Get-WfwStatus -Options $globalOptions
        }
        "list" {
            Get-WfwRule -SubCommand "list" -Arguments $subArgs -Options $globalOptions
        }
        "show" {
            Get-WfwRule -SubCommand "show" -Arguments $subArgs -Options $globalOptions
        }
        "add" {
            Add-WfwRule -Arguments $subArgs -Options $globalOptions
        }
        "allow" {
            # ショートハンド: allow -> add allow
            Add-WfwRule -Arguments (@("allow") + $subArgs) -Options $globalOptions
        }
        "block" {
            # ショートハンド: block -> add block
            Add-WfwRule -Arguments (@("block") + $subArgs) -Options $globalOptions
        }
        "del" {
            Remove-WfwRule -Arguments $subArgs -Options $globalOptions
        }
        "delete" {
            Remove-WfwRule -Arguments $subArgs -Options $globalOptions
        }
        "enable" {
            Set-WfwRule -Action "enable" -Arguments $subArgs -Options $globalOptions
        }
        "disable" {
            Set-WfwRule -Action "disable" -Arguments $subArgs -Options $globalOptions
        }
        "toggle" {
            Set-WfwRule -Action "toggle" -Arguments $subArgs -Options $globalOptions
        }
        "ttl" {
            Invoke-WfwTtl -Arguments $subArgs -Options $globalOptions
        }
        "help" {
            Show-WfwHelp
        }
        "--help" {
            Show-WfwHelp
        }
        "-h" {
            Show-WfwHelp
        }
        "version" {
            Write-Host "wfw version $script:WfwVersion"
        }
        "--version" {
            Write-Host "wfw version $script:WfwVersion"
        }
        "-v" {
            Write-Host "wfw version $script:WfwVersion"
        }
        default {
            Write-Error "不明なコマンド: $subCommand"
            Write-Host "使用可能なコマンド: status, list, show, add, allow, block, del, enable, disable, toggle, ttl, help"
            exit $script:ExitCodes.ArgumentError
        }
    }
}

<#
.SYNOPSIS
    ヘルプメッセージを表示
#>
function Show-WfwHelp {
    $help = @"
wfw - Windows Defender Firewall CLI ツール

使用法:
    wfw <command> [options]

コマンド:
    status              ファイアウォールの状態を表示
    list                ルール一覧を表示
    show <id|name>      ルールの詳細を表示
    add allow|block     ルールを追加
    allow <port>        ポートを許可（add allow のショートハンド）
    block <port>        ポートをブロック（add block のショートハンド）
    del <id|name>       ルールを削除
    enable <id|name>    ルールを有効化
    disable <id|name>   ルールを無効化
    toggle <id|name>    ルールの有効/無効を切り替え
    ttl <subcommand>    一時ルール操作
    help                このヘルプを表示
    version             バージョンを表示

グローバルオプション:
    --json              JSON形式で出力
    --quiet             最小出力
    --verbose           詳細ログ
    --dry-run           実行せず計画のみ表示
    --profile <name>    対象プロファイル (domain|private|public|any)

例:
    wfw status
    wfw allow 443
    wfw allow out 53/udp
    wfw block 3389 --raddr 0.0.0.0/0
    wfw ttl allow 8080 --ttl 10m
    wfw list --json
"@
    Write-Host $help
}

Export-ModuleMember -Function Invoke-Wfw
