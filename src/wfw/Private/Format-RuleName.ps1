#Requires -Version 5.1
<#
.SYNOPSIS
    繝ｫ繝ｼ繝ｫ蜷阪ｒ閾ｪ蜍慕函謌舌☆繧・

.DESCRIPTION
    FWCLI:<action>:<dir>:<proto>:<lport>:<raddr>:<ts> 蠖｢蠑上・繝ｫ繝ｼ繝ｫ蜷阪ｒ逕滓・

.PARAMETER Action
    "allow" 縺ｾ縺溘・ "block"

.PARAMETER Direction
    "in" 縺ｾ縺溘・ "out"

.PARAMETER Protocol
    繝励Ο繝医さ繝ｫ・・cp, udp, icmp, any・・

.PARAMETER LocalPort
    繝ｭ繝ｼ繧ｫ繝ｫ繝昴・繝・

.PARAMETER RemoteAddress
    繝ｪ繝｢繝ｼ繝医い繝峨Ξ繧ｹ

.OUTPUTS
    逕滓・縺輔ｌ縺溘Ν繝ｼ繝ｫ蜷・

.EXAMPLE
    Format-RuleName -Action "allow" -Direction "in" -Protocol "tcp" -LocalPort "443"
    # 蜃ｺ蜉・ FWCLI:allow:in:tcp:443:any:20260205171500
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

    # 繧ｿ繧､繝繧ｹ繧ｿ繝ｳ繝励ｒ逕滓・
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"

    # 繝ｪ繝｢繝ｼ繝医い繝峨Ξ繧ｹ繧堤洒邵ｮ
    $shortAddr = if ($RemoteAddress -eq "Any" -or $RemoteAddress -eq "any") {
        "any"
    }
    elseif ($RemoteAddress.Length -gt 15) {
        # 髟ｷ縺・い繝峨Ξ繧ｹ縺ｯ蜈磯ｭ繧剃ｽｿ逕ｨ
        $RemoteAddress.Substring(0, 12) + "..."
    }
    else {
        $RemoteAddress
    }

    # 繝ｫ繝ｼ繝ｫ蜷阪ｒ讒狗ｯ・
    $name = "FWCLI:$Action`:$Direction`:$Protocol`:$LocalPort`:$shortAddr`:$timestamp"

    return $name
}
