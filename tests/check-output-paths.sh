#!/bin/bash
# check-output-paths.sh - 验证输出路径规范

set -e

ERRORS=0

echo "=== Checking Output Path Compliance ==="

for skill in gm-architecture gm-data-chart; do
    skill_dir="$skill/skills/$skill"

    if [ ! -d "$skill_dir/assets/examples" ]; then
        continue
    fi

    EX_DIR="$skill_dir/assets/examples"
    IMG_DIR="$EX_DIR/images"

    # 检查 images 目录下是否有非图片文件
    if [ -d "$IMG_DIR" ]; then
        non_images=$(find "$IMG_DIR" -type f ! -name "*.png" ! -name "*.jpg" ! -name "*.jpeg" ! -name ".DS_Store" 2>/dev/null || true)
        if [ -n "$non_images" ]; then
            echo "❌ FAIL: $skill/images/ contains non-image files:"
            echo "$non_images" | sed 's/^/  /'
            ERRORS=$((ERRORS + 1))
        else
            echo "✅ PASS: $skill/images/ - only image files"
        fi
    fi

    # 检查 HTML/JSON 是否在根目录
    for json_file in "$EX_DIR"/*.json; do
        [ -f "$json_file" ] || continue
        filename=$(basename "$json_file")
        html_file="${json_file%.json}.html"

        if [ ! -f "$html_file" ]; then
            echo "❌ FAIL: $filename - missing corresponding HTML file"
            ERRORS=$((ERRORS + 1))
        fi
    done

echo "✅ PASS: $skill - HTML/JSON files in correct location"
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All output paths are compliant"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
