# AI Plugins - Claude Code ガイド

## プロジェクト概要

チーム共有のClaude Codeスキル集です。

## 開発ガイドライン

### スキル追加時のルール

1. **SKILL.md 形式に従う**: `skills/{skill-name}/SKILL.md` として作成
2. **allowed-tools を明示**: 必要なツールのみを許可
3. **前提条件を明記**: 必要な外部ツールや認証要件を記載
4. **テンプレートを参考にする**: `skills/_template/SKILL.md` の構造に従う
5. **バリデーションを実行**: スキル追加・変更時は `bash scripts/validate-skills.sh` で検証

### allowed-tools パターン

スキルで許可するツールの記述形式：

| 形式 | 説明 | 例 |
|------|------|-----|
| `ToolName` | ツール全体を許可 | `Read`, `Write` |
| `ToolName(prefix *)` | 特定プレフィックスで始まるコマンドを許可 | `Bash(git diff *)` |
| `ToolName(**)` | ツールの全パターンを許可 | `Read(**)` |

**よく使うパターン例**:
- `Bash(git diff *)`: `git diff` コマンド
- `Bash(gh pr view *)`: GitHub CLI の PR情報取得
- `Bash(test *)`: ファイル存在・サイズ確認（`test -s path/to/file`）

### ファイル構造

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
│   └── {skill-name}/
│       └── SKILL.md          # スキル定義
├── scripts/
│   └── validate-skills.sh    # スキルバリデーション
├── CLAUDE.md                 # 開発ガイドライン
└── README.md
```

## 言語ポリシー

- **ドキュメント・コメント**: 日本語
- **コード・コマンド**: 英語
- **コミットメッセージ**: 日本語
- **PRタイトル・説明**: 日本語

## バージョン管理

`.claude-plugin/plugin.json` の `version` フィールドは[セマンティックバージョニング](https://semver.org/lang/ja/)に従う。

| 変更内容 | バージョン更新 |
|---------|---------------|
| 後方互換性のない変更（スキル名変更、allowed-tools の破壊的変更） | MAJOR |
| 新スキル追加、既存スキルの機能拡張 | MINOR |
| バグ修正、ドキュメント修正 | PATCH |

## Copilotレビューワークフロー

このプロジェクトでは、品質担保のため以下の2つのタイミングでCopilotレビューを実施します。

> **Note**: 以下のワークフローはClaude Code使用時のルールです。`ExitPlanMode`はClaude Codeのplan mode終了コマンド、`/ai-plugins:copilot-review`はこのプロジェクトで提供するスキルです。

### ワークフロー図

```mermaid
flowchart TD
    A[タスク開始] --> B{Plan作成?}
    B -->|Yes| C[planファイル作成]
    C --> D[Copilot CLIでplanレビュー]
    D --> E{指摘あり?}
    E -->|Yes| F[planに反映]
    F --> D
    E -->|No| G[ExitPlanMode]
    B -->|No| H[実装作業]
    G --> H
    H --> I[コード変更完了]
    I --> J[/ai-plugins:copilot-review でレビュー]
    J --> K{指摘あり?}
    K -->|Yes| L[妥当な指摘を反映]
    L --> J
    K -->|No| M[コミット]
    M --> N[タスク完了]
```

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
copilot --model gpt-5.2 --add-dir ~/.claude/plans -s -p "planファイルパス をレビューしてください。抜け漏れや改善点があれば指摘してください。"
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
