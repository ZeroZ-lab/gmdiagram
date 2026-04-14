#!/bin/bash
# check-metadata-version.sh - 验证 metadata 版本规范

set -e

ERRORS=0
WARNINGS=0
SEMVER_PATTERN="^[0-9]+\.[0-9]+\.[0-9]+$"

echo "=== Checking Metadata Version Compliance ==="

for skill_dir in architecture-diagram/skills/architecture-diagram architecture-diagram/skills/data-chart; do
    if [ ! -d "$skill_dir/assets/examples" ]; then
        continue
    fi

    for json_file in "$skill_dir"/assets/examples/*.json; do
        [ -f "$json_file" ] || continue

        filename=$(basename "$json_file")

        # 提取 version
        version=$(python3 -c "
import json
import sys
try:
    data = json.load(open('$json_file'))
    metadata = data.get('metadata', {})
    version = metadata.get('version', '')
    print(version)
except Exception as e:
    print('ERROR', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null)

        if [ -z "$version" ]; then
            echo "❌ FAIL: $filename - missing metadata.version"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        # 检查是否为占位符
        if [ "$version" = "1.0" ] || [ "$version" = "1.0.0" ] || [ "$version" = "0.0.0" ]; then
            echo "❌ FAIL: $filename - placeholder version '$version' not allowed"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        # 检查 SemVer 格式
        if ! [[ $version =~ $SEMVER_PATTERN ]]; then
            echo "❌ FAIL: $filename - version '$version' not in SemVer format (x.y.z)"
            ERRORS=$((ERRORS + 1))
            continue
        fi

        echo "✅ PASS: $filename - version='$version'"
    done
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All metadata versions are compliant"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
