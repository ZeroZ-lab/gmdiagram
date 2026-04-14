#!/bin/bash
# check-file-naming.sh - 验证文件命名规范

set -e

ERRORS=0
KEBAB_PATTERN="^[a-z0-9]+(-[a-z0-9]+)*\.(json|html)$"

echo "=== Checking File Naming Convention Compliance ==="

for skill in architecture-diagram data-chart; do
    skill_dir="architecture-diagram/skills/$skill"

    if [ ! -d "$skill_dir/assets/examples" ]; then
        continue
    fi

    for file in "$skill_dir"/assets/examples/*.{json,html}; do
        [ -f "$file" ] || continue

        filename=$(basename "$file")

        # 跳过 .DS_Store 等系统文件
        if [[ $filename == .DS_Store ]]; then
            continue
        fi

        if ! [[ $filename =~ $KEBAB_PATTERN ]]; then
            echo "❌ FAIL: $filename - not in kebab-case format"
            ERRORS=$((ERRORS + 1))
        else
            echo "✅ PASS: $filename"
        fi
    done
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All filenames are compliant"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
