#!/bin/bash
# スキル定義の簡易バリデーション
# SKILL.mdの必須項目（name, description, allowed-tools）をチェック

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PROJECT_ROOT/skills"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

total_error_count=0

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
        ((total_error_count++))
        continue
    fi

    # フロントマターを抽出（最初の---から次の---まで）
    frontmatter=$(awk '/^---$/{if(f)exit;f=1;next}f' "$skill_file")

    # フロントマターの必須項目チェック
    # name:
    if ! echo "$frontmatter" | grep -q "^name:"; then
        echo -e "${RED}ERROR${NC}: $skill_file に name: がありません"
        ((skill_error_count++))
    elif echo "$frontmatter" | grep -q "^name: *$"; then
        echo -e "${RED}ERROR${NC}: $skill_file の name: が空です"
        ((skill_error_count++))
    fi

    # description:
    if ! echo "$frontmatter" | grep -q "^description:"; then
        echo -e "${RED}ERROR${NC}: $skill_file に description: がありません"
        ((skill_error_count++))
    elif echo "$frontmatter" | grep -q "^description: *$"; then
        echo -e "${RED}ERROR${NC}: $skill_file の description: が空です"
        ((skill_error_count++))
    fi

    # allowed-tools:
    if ! echo "$frontmatter" | grep -q "^allowed-tools:"; then
        echo -e "${RED}ERROR${NC}: $skill_file に allowed-tools: がありません"
        ((skill_error_count++))
    elif echo "$frontmatter" | grep -q "^allowed-tools: *$"; then
        echo -e "${RED}ERROR${NC}: $skill_file の allowed-tools: が空です"
        ((skill_error_count++))
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
