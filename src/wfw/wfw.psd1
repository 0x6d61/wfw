@{
    # モジュール識別情報
    RootModule           = 'wfw.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author               = '0x6d61'
    CompanyName          = ''
    Copyright            = '(c) 2026 0x6d61. MIT License.'
    Description          = 'Windows Defender Firewall CLI ツール - ufw/iptables風の短いコマンドでファイアウォールを操作'

    # 動作要件
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    # エクスポートする関数
    FunctionsToExport    = @(
        'Invoke-Wfw',
        'Get-WfwStatus',
        'Get-WfwRule',
        'Add-WfwRule',
        'Remove-WfwRule',
        'Set-WfwRule',
        'Invoke-WfwTtl'
    )

    # エクスポートする変数・エイリアス
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    # プライベートデータ
    PrivateData          = @{
        PSData = @{
            Tags       = @('Firewall', 'Windows', 'NetSecurity', 'CLI')
            LicenseUri = 'https://github.com/0x6d61/wfw/blob/main/LICENSE'
            ProjectUri = 'https://github.com/0x6d61/wfw'
        }
    }
}
