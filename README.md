# AI Plugins

チーム共有のClaude Codeスキル集です。

## 含まれるスキル

| スキル名 | 説明 |
|---------|------|
| `copilot-review` | GitHub Copilot CLIを使ってコードレビューを依頼 |

## インストール方法

### 方法1: GitHub URLから直接インストール（推奨）

クローン不要で更新も楽なため推奨。

```bash
# マーケットプレイスを追加
/plugin marketplace add shogidemo/ai-plugins

# プラグインをインストール
/plugin install ai-plugins@ai-plugins

# インストール確認
/plugin list
```

### 方法2: クローンしてインストール

ローカルでカスタマイズしたい場合向け。

```bash
git clone git@github.com:shogidemo/ai-plugins.git ~/.claude/plugins/ai-plugins
claude --plugin-dir ~/.claude/plugins/ai-plugins
```

## 使用方法

### copilot-review

GitHub Copilot CLIを使ってコードレビューを依頼するスキルです。

**呼び出し方法:**
```
/ai-plugins:copilot-review
```

**使用例:**
```
/ai-plugins:copilot-review 現在の変更をレビューして
/ai-plugins:copilot-review PR #123 をレビューして
/ai-plugins:copilot-review src/main.py をレビューして
```

## 前提条件

このプラグインのスキルを使用するには、以下の環境が必要です：

| 項目 | 要件 |
|------|------|
| GitHub CLI (`gh`) | インストール済み・認証済み |
| Copilot CLI (`copilot`) | インストール済み・PATH設定済み |
| GitHub認証 | `gh auth login` 完了 |

**前提条件の確認方法:**
```bash
# Copilot CLIの確認
copilot --version

# GitHub認証状態の確認
gh auth status
```

## 更新方法

### 方法1でインストールした場合

```bash
/plugin marketplace update ai-plugins
```

### 方法2でインストールした場合

```bash
cd ~/.claude/plugins/ai-plugins && git pull
```

## 開発・貢献

### ローカルでのテスト

リポジトリをクローンしてローカルでテストする場合：

```bash
# リポジトリをクローン
git clone git@github.com:shogidemo/ai-plugins.git
cd ai-plugins

# プラグインを読み込んでClaude Codeを起動
claude --plugin-dir .
```

起動後、以下のコマンドでスキルが認識されていることを確認：

    /ai-plugins:copilot-review

**動作確認チェックリスト:**
- スキルが `/ai-plugins:copilot-review` で呼び出せる
- `copilot --version` でCopilot CLIが利用可能
- `gh auth status` でGitHub認証済み
- `bash scripts/validate-skills.sh` でバリデーションが通る

### プラグインの構造

```
ai-plugins/
├── .claude/
│   └── settings.json         # プロジェクト設定
├── .claude-plugin/
│   ├── plugin.json           # プラグインマニフェスト
│   └── marketplace.json      # マーケットプレイス設定
├── skills/
│   ├── _template/
│   │   └── SKILL.md          # スキルテンプレート
│   └── copilot-review/
│       └── SKILL.md          # スキル定義
├── scripts/
│   └── validate-skills.sh    # スキルバリデーション
├── CLAUDE.md                 # 開発ガイドライン
└── README.md
```

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照
