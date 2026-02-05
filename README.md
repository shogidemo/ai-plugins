# Annex AI Plugins

Annex開発チーム共有のClaude Codeスキル集です。

## 含まれるスキル

| スキル名 | 説明 |
|---------|------|
| `copilot-review` | GitHub Copilot CLIを使ってコードレビューを依頼 |

## インストール方法

### 1. プラグインをクローン

```bash
git clone git@github.com:shogidemo/annex-ai-plugins.git ~/.claude/plugins/annex
```

### 2. Claude Codeを起動

```bash
claude --plugin-dir ~/.claude/plugins/annex
```

## 使用方法

### copilot-review

GitHub Copilot CLIを使ってコードレビューを依頼するスキルです。

**呼び出し方法:**
```
/annex:copilot-review
```

**使用例:**
```
/annex:copilot-review 現在の変更をレビューして
/annex:copilot-review PR #123 をレビューして
/annex:copilot-review src/main.py をレビューして
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

```bash
cd ~/.claude/plugins/annex && git pull
```

## 開発・貢献

### ローカルでのテスト

```bash
claude --plugin-dir ./annex-ai-plugins
```

### プラグインの構造

```
annex-ai-plugins/
├── .claude-plugin/
│   └── plugin.json       # プラグインマニフェスト
├── skills/
│   └── copilot-review/
│       └── SKILL.md      # スキル定義
└── README.md
```

## ライセンス

MIT License
