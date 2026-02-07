---
name: codex-assist
description: Asks Codex CLI for coding assistance. Use for getting a second opinion, code generation, debugging, or delegating coding tasks.
allowed-tools: Bash(codex *), Bash(test *)
---

# Codex アシスタント

Codex CLI (`codex`) を使ってコード作成・レビュー・デバッグなどの支援を受けるスキル。

> **allowed-tools の用途説明**:
> - `Bash(codex *)`: Codex CLI実行（バージョン確認・exec サブコマンド等）
> - `Bash(test *)`: ファイル存在・サイズ確認

## 前提条件（必須）

このスキルを使用するには、以下の環境が必要です：

| 項目 | 要件 |
|------|------|
| Codex CLI (`codex`) | インストール済み・PATH設定済み |
| Git リポジトリ | `-C` オプションで指定（必須） |
| Config ファイル | `~/.codex/config.toml` で設定可能（任意） |

**前提条件の確認方法:**
```bash
# Codex CLIの確認
codex --version

# 動作確認（gitリポジトリ内で実行）
codex exec -C /path/to/git-repo "hello"
```

## レビュー依頼時の必須設定

**重要**: コードレビュー、計画レビュー、設計レビューなどを依頼する際は、**必ず**以下の設定を使用すること。これは例外なく適用される必須ルールである。

- **モデル**: `gpt-5.2`（他のモデルを使用してはならない）
- **推論レベル**: `medium`
- **作業ディレクトリ**: `-C` オプションでgitリポジトリを指定（**必須**）

```bash
codex exec -m gpt-5.2 -c 'model_reasoning_effort="medium"' -C /path/to/git-repo "レビュー内容"
```

以下のキーワードが含まれる場合は、上記設定を使用すること：
- レビュー / review
- 確認 / check
- 評価 / evaluate
- 検証 / verify / validate
- フィードバック / feedback

## Claude Code実行環境での制約事項

**以下はClaude Codeの実行環境では動作しないため使用禁止:**

```bash
# NG: パイプ入力（stdin is not a terminal エラー）
cat file.txt | codex exec ...

# NG: リダイレクト入力（同上）
codex exec ... - < file.txt

# NG: バックグラウンド実行（stdinエラー）
codex exec ... &
```

**代わりに、プロンプト内でファイルパスを指定すること:**

```bash
# OK: ファイルパスをプロンプトで指定
codex exec -m gpt-5.2 -c 'model_reasoning_effort="medium"' \
  -C /path/to/git-repo \
  "ファイル /tmp/target-file.txt を読んでレビューしてください"
```

## 使用方法

### レビュー依頼（必須設定を使用）

```bash
codex exec -m gpt-5.2 -c 'model_reasoning_effort="medium"' -C /path/to/git-repo "レビュー内容"
```

### PRの差分をレビュー

PR差分は事前に一時ファイルへ保存してから、ファイルパスで指定する。

```bash
# Step 1: 差分を一時ファイルに保存（このスキルの scope 外、事前に実行すること）
gh pr diff 123 --repo owner/repo > /tmp/pr-123-diff.txt

# Step 2: ファイルパスをプロンプトで指定してレビュー依頼
codex exec -m gpt-5.2 -c 'model_reasoning_effort="medium"' \
  -C /path/to/project \
  "ファイル /tmp/pr-123-diff.txt を読んで、セキュリティ観点を含めてレビューしてください"
```

### 特定ファイルのレビュー

```bash
# Step 1: ファイル存在確認
test -s src/main.py

# Step 2: ファイルパスをプロンプトで指定
codex exec -m gpt-5.2 -c 'model_reasoning_effort="medium"' \
  -C /path/to/project \
  "src/main.py をレビューしてください"
```

### 簡単な質問（モデル指定なし）

```bash
codex exec -C /path/to/project "How do I implement a binary search in Python?"
```

### 自動実行モード

```bash
codex exec --full-auto -C /path/to/project "Add error handling to all API endpoints"
```

**注意**: `--full-auto` はサンドボックス内でファイルを自動変更するため、変更内容を必ず確認すること。

## 主要オプション

| オプション | 説明 |
|-----------|------|
| `-m MODEL` | 使用するモデルを指定（レビュー時は `gpt-5.2` 必須） |
| `-c KEY=VALUE` | 設定オプション。値はTOMLとして解釈される |
| `-C DIR` | 作業ディレクトリを指定（**必須**: gitリポジトリ） |
| `--full-auto` | サンドボックス内で自動実行を有効化 |

### Config Options (-c)

値はTOMLとして解釈される。文字列は必ずダブルクォートで囲むこと。

| キー | 説明 |
|-----|------|
| `model="MODEL"` | モデル指定（-m の代替） |
| `model_reasoning_effort="LEVEL"` | 推論レベル: low, medium, high, xhigh |
| `hide_agent_reasoning=true\|false` | 推論プロセスの表示/非表示 |

## セキュリティに関する注意

**重要**: レビュー対象に機密情報が含まれないよう注意してください。

- `.env` ファイル、認証情報、APIキーを含むファイルはレビュー対象から除外
- 個人情報（PII）を含むデータは送信前にマスク
- `-C` オプションで作業スコープを限定することを推奨

## トラブルシューティング

### `codex` コマンドが見つからない

```bash
# インストール確認
codex --version
```

**インストール**: 利用している `codex` CLI の公式ドキュメントに従ってインストールしてください。

### "Not inside a trusted directory" エラー

**原因**: `-C` オプションでgitリポジトリを指定していない。

**対処法**:
```bash
# -C オプションでgitリポジトリのパスを指定
codex exec -C /path/to/git-repo "your question"
```

### stdin関連のエラー（Claude Code環境）

**症状**: `stdin is not a terminal` エラーが発生する。

**原因**: Claude Codeの実行環境ではパイプ/リダイレクト入力が動作しない。

**対処法**: プロンプト内でファイルパスを直接指定する。
```bash
# Step 1: 対象ファイルの存在確認
test -s /path/to/file.txt

# Step 2: ファイルパスをプロンプトで指定
codex exec -m gpt-5.2 -c 'model_reasoning_effort="medium"' \
  -C /path/to/git-repo \
  "ファイル /path/to/file.txt を読んでレビューしてください"
```

## Notes

- Codex は `exec` サブコマンドで非対話的に実行される
- デフォルトでは出力は標準出力に送られ、ファイルは変更されない
- `--full-auto` で自動実行を有効化できるが、変更内容の確認を推奨
- **`-C` オプションでgitリポジトリを指定することが必須**
- Model defaults は `~/.codex/config.toml` で設定可能
- **レビュー依頼時は必ず `-m gpt-5.2 -c 'model_reasoning_effort="medium"'` を指定すること**
- **Claude Code環境ではパイプ/リダイレクト入力は使用不可** - 代わりにプロンプト内でファイルパスを指定
