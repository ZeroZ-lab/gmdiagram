#!/bin/bash
# check-metadata-complete.sh - 验证 metadata 字段完整性

set -e

ERRORS=0
DATE_PATTERN="^[0-9]{4}-[0-9]{2}-[0-9]{2}$"

echo "=== Checking Metadata Field Completeness ==="

for skill_dir in gm-architecture/skills/gm-architecture gm-data-chart/skills/gm-data-chart; do
    if [ ! -d "$skill_dir/assets/examples" ]; then
        continue
    fi

    for json_file in "$skill_dir"/assets/examples/*.json; do
        [ -f "$json_file" ] || continue

        filename=$(basename "$json_file")

        result=$(python3 << EOF 2>/dev/null
import json
import re
import sys

try:
    with open('$json_file', 'r', encoding='utf-8') as f:
        data = json.load(f)

    metadata = data.get('metadata', {})
    required = ['author', 'date', 'version']
    missing = [f for f in required if f not in metadata]

    if missing:
        print(f"MISSING:{','.join(missing)}")
        sys.exit(1)

    # 检查 author
    if metadata.get('author') != 'gmdiagram':
        print(f"WRONG_AUTHOR:{metadata.get('author')}")
        sys.exit(1)

    # 检查 date 格式
    date = metadata.get('date', '')
    if not re.match(r'^\d{4}-\d{2}-\d{2}$', date):
        print(f"INVALID_DATE:{date}")
        sys.exit(1)

    print("PASS")
except Exception as e:
    print(f"ERROR:{e}")
    sys.exit(1)
EOF
)

        if [ "$result" != "PASS" ]; then
            echo "❌ FAIL: $filename - $result"
            ERRORS=$((ERRORS + 1))
        else
            echo "✅ PASS: $filename"
        fi
    done
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All metadata fields are complete"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
