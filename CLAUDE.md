# AI Plugins - Claude Code ガイド

## プロジェクト概要

チーム共有のClaude Codeスキル集です。

## 開発ガイドライン

### スキル追加時のルール

1. **SKILL.md 形式に従う**: `skills/{skill-name}/SKILL.md` として作成
2. **allowed-tools を明示**: 必要なツールのみを許可
3. **前提条件を明記**: 必要な外部ツールや認証要件を記載

### ファイル構造

```
ai-plugins/
├── .claude-plugin/
│   └── plugin.json       # プラグインマニフェスト
├── .claude/
│   └── settings.json     # プロジェクト設定
├── skills/
│   └── {skill-name}/
│       └── SKILL.md      # スキル定義
└── README.md
```

## 言語ポリシー

- **ドキュメント・コメント**: 日本語
- **コード・コマンド**: 英語
- **コミットメッセージ**: 日本語
- **PRタイトル・説明**: 日本語

## Copilotレビューワークフロー

このプロジェクトでは、品質担保のため以下の2つのタイミングでCopilotレビューを実施します。

> **Note**: 以下のワークフローはClaude Code使用時のルールです。`ExitPlanMode`はClaude Codeのplan mode終了コマンド、`/ai-plugins:copilot-review`はこのプロジェクトで提供するスキルです。

### planファイルについて

- **保存場所**: `~/.claude/plans/` 配下（セッション領域）
- **コミット対象外**: planファイルはリポジトリにコミットしない
- planは作業の計画段階で使用し、実装完了後は不要となるため

### 1. Plan作成時のレビュー（必須）

**タイミング**: ExitPlanMode呼び出し前

**手順**:
1. planファイル作成後、Copilot CLIでレビューを依頼
2. Copilotの指摘を確認し、妥当なものをplanに反映
3. planファイルを更新後、ExitPlanModeを呼び出す

**コマンド例**:
```bash
copilot --model gpt-5.2 --add-dir "$(dirname planファイル)" -s -p "$(pwd)/planファイル をレビューしてください。抜け漏れや改善点があれば指摘してください。"
```

※このレビューをスキップしてExitPlanModeを呼び出すことは禁止

### 2. 対応完了後のレビュー（必須）

**タイミング**: コード変更完了後、コミット前

**手順**:
1. 変更完了後、`/ai-plugins:copilot-review` スキルでレビューを依頼
2. Copilotの指摘を確認し、妥当なものを反映
3. レビュー対応後、コミットを実施

**レビューの哲学**:
- レビュー指摘は「提案」であり「命令」ではない
- 最終判断は開発者（Claude Code）が行う
- Copilotは優秀だが、常に正しいとは限らない
