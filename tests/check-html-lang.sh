#!/bin/bash
# check-html-lang.sh - 验证 HTML lang 属性

set -e

ERRORS=0
VALID_LANGS="^(en|zh-CN|zh-TW|ja|ko|de|fr|es)$"

echo "=== Checking HTML Lang Attribute Compliance ==="

for skill in gm-architecture gm-data-chart; do
    skill_dir="$skill/skills/$skill"

    if [ ! -d "$skill_dir/assets/examples" ]; then
        continue
    fi

    for html_file in "$skill_dir"/assets/examples/*.html; do
        [ -f "$html_file" ] || continue

        filename=$(basename "$html_file")

        # 提取 lang 属性 (兼容 BSD 和 GNU grep)
        lang=$(grep -o 'lang="[^"]*"' "$html_file" 2>/dev/null | head -1 | sed 's/lang="\([^"]*\)"/\1/' || true)

        if [ -z "$lang" ]; then
            echo "❌ FAIL: $filename - missing lang attribute"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        if ! [[ $lang =~ $VALID_LANGS ]]; then
            echo "❌ FAIL: $filename - invalid lang value '$lang'"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        echo "✅ PASS: $filename - lang='$lang'"
    done
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All HTML lang attributes are compliant"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
