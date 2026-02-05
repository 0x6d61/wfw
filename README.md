# wfw - Windows Defender Firewall CLI

Windows Defender Firewall を ufw/iptables 風の短いコマンドで操作する CLI ツール。

## 特徴

- 🚀 **シンプルなコマンド**: `wfw allow 443` のような直感的な構文
- ⏰ **一時ルール (TTL)**: 指定時間後に自動削除されるルール
- 🏷️ **タグ管理**: ルールをグループ化して管理
- 📊 **JSON出力**: スクリプトとの連携が容易

## 動作要件

- Windows 10/11 または Windows Server 2016+
- PowerShell 5.1 以上
- 管理者権限（ルール作成/削除/有効化/無効化時）

## インストール

```powershell
# リポジトリをクローン
git clone https://github.com/0x6d61/wfw.git
cd wfw

# モジュールをインポート（一時的）
Import-Module .\src\wfw\wfw.psd1

# または、wfw.ps1 を直接実行
.\wfw.ps1 status
```

## 使用例

### 基本的な操作

```powershell
# ファイアウォールの状態を確認
wfw status

# ポート443を許可（インバウンド/TCP）
wfw allow 443

# ポート3389をブロック
wfw block 3389

# アウトバウンドでDNSを許可
wfw allow out 53/udp

# 特定アドレスからのみ許可
wfw allow 22 --raddr 10.0.0.0/8
```

### ルール管理

```powershell
# FWCLI管理下のルール一覧
wfw list

# 特定ルールの詳細
wfw show <rule-id>

# ルールを無効化
wfw disable <rule-id>

# ルールを削除
wfw del <rule-id>
```

### 一時ルール (TTL)

```powershell
# 10分間だけポート8080を開放
wfw ttl allow 8080 --ttl 10m

# 一時ルール一覧
wfw ttl list

# 期限切れルールを削除
wfw ttl reap
```

### JSON出力

```powershell
# JSON形式で出力
wfw list --json
```

## コマンド一覧

| コマンド | 説明 | 権限 |
|----------|------|------|
| `wfw status` | ファイアウォール状態表示 | 不要 |
| `wfw list` | ルール一覧 | 不要 |
| `wfw show <id>` | ルール詳細 | 不要 |
| `wfw add allow/block` | ルール追加 | **管理者** |
| `wfw del <id>` | ルール削除 | **管理者** |
| `wfw enable <id>` | ルール有効化 | **管理者** |
| `wfw disable <id>` | ルール無効化 | **管理者** |
| `wfw ttl add` | 一時ルール追加 | **管理者** |
| `wfw ttl list` | 一時ルール一覧 | 不要 |
| `wfw ttl reap` | 期限切れ削除 | **管理者** |

## グローバルオプション

| オプション | 説明 |
|------------|------|
| `--json` | JSON形式で出力 |
| `--quiet` | 最小出力 |
| `--verbose` | 詳細ログ |
| `--dry-run` | 実行せず計画のみ表示 |
| `--profile <domain\|private\|public\|any>` | 対象プロファイル |

## ライセンス

MIT License
