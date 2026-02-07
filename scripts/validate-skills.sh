#!/bin/bash
# プラグインバリデーション
# plugin.json のマニフェスト検証 + SKILL.md の必須項目チェック

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PROJECT_ROOT/skills"
PLUGIN_JSON="$PROJECT_ROOT/.claude-plugin/plugin.json"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

total_error_count=0

# --- plugin.json バリデーション ---
echo "=== plugin.json バリデーション ==="

# jq の存在チェック
if ! command -v jq &>/dev/null; then
    echo -e "${RED}ERROR${NC}: jq がインストールされていません。brew install jq などでインストールしてください"
    exit 1
fi

# plugin.json の存在確認
if [[ ! -f "$PLUGIN_JSON" ]]; then
    echo -e "${RED}ERROR${NC}: $PLUGIN_JSON が見つかりません"
    ((total_error_count++)) || true
else
    # JSON パース確認
    if ! jq empty "$PLUGIN_JSON" 2>/dev/null; then
        echo -e "${RED}ERROR${NC}: $PLUGIN_JSON は有効なJSONではありません"
        ((total_error_count++)) || true
    else
        # name フィールド（必須・非空文字列）
        name_type=$(jq -r 'if .name then .name | type else "missing" end' "$PLUGIN_JSON")
        if [[ "$name_type" == "missing" ]]; then
            echo -e "${RED}ERROR${NC}: plugin.json に name フィールドがありません（必須）"
            ((total_error_count++)) || true
        elif [[ "$name_type" != "string" ]]; then
            echo -e "${RED}ERROR${NC}: plugin.json の name は文字列である必要があります（現在: ${name_type}）"
            ((total_error_count++)) || true
        else
            name_value=$(jq -r '.name' "$PLUGIN_JSON")
            if [[ -z "$name_value" ]]; then
                echo -e "${RED}ERROR${NC}: plugin.json の name が空文字です"
                ((total_error_count++)) || true
            fi
        fi

        # version フィールド（任意・文字列・semver形式）
        has_version=$(jq 'has("version")' "$PLUGIN_JSON")
        if [[ "$has_version" == "true" ]]; then
            version_type=$(jq -r '.version | type' "$PLUGIN_JSON")
            if [[ "$version_type" != "string" ]]; then
                echo -e "${RED}ERROR${NC}: plugin.json の version は文字列である必要があります（現在: ${version_type}）"
                ((total_error_count++)) || true
            else
                version_value=$(jq -r '.version' "$PLUGIN_JSON")
                if ! echo "$version_value" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.\-]+)?(\+[a-zA-Z0-9.\-]+)?$'; then
                    echo -e "${RED}ERROR${NC}: plugin.json の version '$version_value' はセマンティックバージョニング形式ではありません"
                    ((total_error_count++)) || true
                fi
            fi
        fi

        # repository フィールド（任意・文字列）
        has_repository=$(jq 'has("repository")' "$PLUGIN_JSON")
        if [[ "$has_repository" == "true" ]]; then
            repo_type=$(jq -r '.repository | type' "$PLUGIN_JSON")
            if [[ "$repo_type" != "string" ]]; then
                echo -e "${RED}ERROR${NC}: plugin.json の repository は文字列である必要があります（現在: ${repo_type}）。URL文字列を指定してください"
                ((total_error_count++)) || true
            fi
        fi

        # エラーがなければOK
        if [[ $total_error_count -eq 0 ]]; then
            echo -e "${GREEN}OK${NC}: $PLUGIN_JSON"
        fi
    fi
fi

echo ""
echo "=== スキルバリデーション ==="

# skills配下のディレクトリを走査（_templateは除外）
for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")

    # _templateは検証対象外
    if [[ "$skill_name" == "_template" ]]; then
        echo "SKIP: $skill_name (テンプレート)"
        continue
    fi

    skill_file="$skill_dir/SKILL.md"
    skill_error_count=0

    # SKILL.mdの存在確認
    if [[ ! -f "$skill_file" ]]; then
        echo -e "${RED}ERROR${NC}: $skill_dir にSKILL.mdがありません"
        ((total_error_count++)) || true
        continue
    fi

    # フロントマターを抽出（最初の---から次の---まで）
    frontmatter=$(awk '/^---$/{if(f)exit;f=1;next}f' "$skill_file")

    # フロントマターの必須項目チェック
    # name:
    if ! echo "$frontmatter" | grep -q "^name:"; then
        echo -e "${RED}ERROR${NC}: $skill_file に name: がありません"
        ((skill_error_count++)) || true
    elif echo "$frontmatter" | grep -q "^name: *$"; then
        echo -e "${RED}ERROR${NC}: $skill_file の name: が空です"
        ((skill_error_count++)) || true
    else
        # kebab-case形式チェック（小文字、数字、ハイフンのみ許可、先頭・末尾ハイフン禁止）
        name_value=$(echo "$frontmatter" | grep "^name:" | sed 's/^name: *//')
        if [[ "$name_value" == "my-skill-name" ]]; then
            echo -e "${RED}ERROR${NC}: $skill_file の name: がテンプレートのまま ('my-skill-name') です"
            ((skill_error_count++)) || true
        elif ! echo "$name_value" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
            echo -e "${RED}ERROR${NC}: $skill_file の name: '$name_value' は kebab-case形式ではありません"
            ((skill_error_count++)) || true
        fi
    fi

    # description:
    if ! echo "$frontmatter" | grep -q "^description:"; then
        echo -e "${RED}ERROR${NC}: $skill_file に description: がありません"
        ((skill_error_count++)) || true
    elif echo "$frontmatter" | grep -q "^description: *$"; then
        echo -e "${RED}ERROR${NC}: $skill_file の description: が空です"
        ((skill_error_count++)) || true
    fi

    # allowed-tools:
    if ! echo "$frontmatter" | grep -q "^allowed-tools:"; then
        echo -e "${RED}ERROR${NC}: $skill_file に allowed-tools: がありません"
        ((skill_error_count++)) || true
    elif echo "$frontmatter" | grep -q "^allowed-tools: *$"; then
        echo -e "${RED}ERROR${NC}: $skill_file の allowed-tools: が空です"
        ((skill_error_count++)) || true
    else
        # allowed-tools の形式チェック（警告のみ）
        # 有効な形式: ToolName, ToolName(pattern), ToolName(**)
        allowed_tools=$(echo "$frontmatter" | grep "^allowed-tools:" | sed 's/^allowed-tools: *//')
        # カンマ区切りで各ツールをチェック
        IFS=',' read -ra tools <<< "$allowed_tools"
        for tool in "${tools[@]}"; do
            tool=$(echo "$tool" | sed 's/^ *//;s/ *$//')  # トリム
            # 形式: 大文字始まりの英字 + オプションで括弧内にパターン
            if ! echo "$tool" | grep -qE '^[A-Z][a-zA-Z]*(\([^)]+\))?$'; then
                echo -e "${YELLOW}WARNING${NC}: $skill_file の allowed-tools に不正な形式の可能性: '$tool'"
            fi
        done
    fi

    # 本文を抽出（フロントマター以降）
    body=$(awk '/^---$/{if(f){p=1;next}f=1;next}p' "$skill_file")

    # 前提条件セクションの存在チェック
    if ! echo "$body" | grep -q "^## 前提条件"; then
        echo -e "${RED}ERROR${NC}: $skill_file に ## 前提条件 セクションがありません"
        ((skill_error_count++)) || true
    fi

    # テンプレート残存検出
    if echo "$body" | grep -q "^## テンプレート使用時の注意"; then
        echo -e "${RED}ERROR${NC}: $skill_file にテンプレートセクション '## テンプレート使用時の注意' が残っています"
        ((skill_error_count++)) || true
    fi

    # テンプレートプレースホルダー検出
    if echo "$body" | grep -q "my-skill-name"; then
        echo -e "${RED}ERROR${NC}: $skill_file にテンプレートプレースホルダー 'my-skill-name' が残っています"
        ((skill_error_count++)) || true
    fi

    # スキル単位の結果表示
    if [[ $skill_error_count -eq 0 ]]; then
        echo -e "${GREEN}OK${NC}: $skill_file"
    else
        ((total_error_count += skill_error_count))
    fi
done

# 結果サマリー
echo ""
if [[ $total_error_count -eq 0 ]]; then
    echo -e "${GREEN}全スキルのバリデーション完了${NC}"
    exit 0
else
    echo -e "${RED}バリデーションエラー: $total_error_count 件${NC}"
    exit 1
fi
