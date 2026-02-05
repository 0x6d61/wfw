#Requires -Version 5.1
<#
.SYNOPSIS
    ルール名を自動生成する

.DESCRIPTION
    FWCLI:<action>:<dir>:<proto>:<lport>:<raddr>:<ts> 形式のルール名を生成

.PARAMETER Action
    "allow" または "block"

.PARAMETER Direction
    "in" または "out"

.PARAMETER Protocol
    プロトコル（tcp, udp, icmp, any）

.PARAMETER LocalPort
    ローカルポート

.PARAMETER RemoteAddress
    リモートアドレス

.OUTPUTS
    生成されたルール名

.EXAMPLE
    Format-RuleName -Action "allow" -Direction "in" -Protocol "tcp" -LocalPort "443"
    # 出力: FWCLI:allow:in:tcp:443:any:20260205171500
#>
function Format-RuleName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("allow", "block")]
        [string]$Action,

        [Parameter()]
        [ValidateSet("in", "out")]
        [string]$Direction = "in",

        [Parameter()]
        [string]$Protocol = "tcp",

        [Parameter()]
        [string]$LocalPort = "any",

        [Parameter()]
        [string]$RemoteAddress = "any"
    )

    # タイムスタンプを生成
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"

    # リモートアドレスを短縮
    $shortAddr = if ($RemoteAddress -eq "Any" -or $RemoteAddress -eq "any") {
        "any"
    }
    elseif ($RemoteAddress.Length -gt 15) {
        # 長いアドレスは先頭を使用
        $RemoteAddress.Substring(0, 12) + "..."
    }
    else {
        $RemoteAddress
    }

    # ルール名を構築
    $name = "FWCLI:$Action`:$Direction`:$Protocol`:$LocalPort`:$shortAddr`:$timestamp"

    return $name
}
