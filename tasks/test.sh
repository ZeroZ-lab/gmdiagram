#!/usr/bin/env bash
# gmdiagram Test Suite
# Validates schemas, file structure, cross-references, and content integrity
set -uo pipefail

PASS=0
FAIL=0
ERRORS=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { PASS=$((PASS+1)); echo "  ${GREEN}✓${NC} $1"; }
fail() { FAIL=$((FAIL+1)); ERRORS="$ERRORS\n  ${RED}✗${NC} $1"; echo "  ${RED}✗${NC} $1"; }
skip() { echo "  ${YELLOW}⊘${NC} $1 (skipped)"; }

BASE="/Users/zhengjianqiao/workspace/gmdiagram/architecture-diagram/skills/architecture-diagram"

echo "====================================="
echo "  gmdiagram Test Suite"
echo "====================================="
echo ""

# ===========================================
# Test 1: File Structure
# ===========================================
echo "=== 1. File Structure ==="

# SKILL.md exists
[ -f "$BASE/SKILL.md" ] && pass "SKILL.md exists" || fail "SKILL.md missing"

# README.md exists
[ -f "$BASE/README.md" ] && pass "README.md exists" || fail "README.md missing"

# 5 JSON schemas
for type in architecture flowchart mindmap er sequence; do
  [ -f "$BASE/assets/schema-${type}.json" ] && pass "schema-${type}.json exists" || fail "schema-${type}.json missing"
done

# 9 template HTML files
for style in dark sketch light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream; do
  case $style in
    sketch) template="template-sketch" ;;
    dark) template="template-dark" ;;
    *) template="template-${style}" ;;
  esac
  [ -f "$BASE/assets/${template}.html" ] && pass "${template}.html exists" || fail "${template}.html missing"
done

# 9 style reference files
for style in dark-professional hand-drawn light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream; do
  [ -f "$BASE/references/style-${style}.md" ] && pass "style-${style}.md exists" || fail "style-${style}.md missing"
done

# 5 diagram reference files
for type in architecture flowchart mindmap er sequence; do
  [ -f "$BASE/references/diagram-${type}.md" ] && pass "diagram-${type}.md exists" || fail "diagram-${type}.md missing"
done

# 5 layout reference files (layout-rules.md for architecture, layout-*.md for others)
[ -f "$BASE/references/layout-rules.md" ] && pass "layout-rules.md exists" || fail "layout-rules.md missing"
for type in flowchart mindmap er sequence; do
  [ -f "$BASE/references/layout-${type}.md" ] && pass "layout-${type}.md exists" || fail "layout-${type}.md missing"
done

# 4+ component reference files
for type in flowchart mindmap er sequence; do
  [ -f "$BASE/references/components-${type}.md" ] && pass "components-${type}.md exists" || fail "components-${type}.md missing"
done
[ -f "$BASE/references/component-templates.md" ] && pass "component-templates.md exists" || fail "component-templates.md missing"

# Output format files
for fmt in svg mermaid png-pdf; do
  [ -f "$BASE/references/output-${fmt}.md" ] && pass "output-${fmt}.md exists" || fail "output-${fmt}.md missing"
done

# Icons catalog
[ -f "$BASE/references/icons-catalog.md" ] && pass "icons-catalog.md exists" || fail "icons-catalog.md missing"

# Export script
[ -f "$BASE/scripts/export.sh" ] && pass "scripts/export.sh exists" || fail "scripts/export.sh missing"
[ -x "$BASE/scripts/export.sh" ] && pass "scripts/export.sh is executable" || fail "scripts/export.sh not executable"
[ -f "$BASE/scripts/package.json" ] && pass "scripts/package.json exists" || fail "scripts/package.json missing"

# Diagram type registry
[ -f "$BASE/references/diagram-type-registry.md" ] && pass "diagram-type-registry.md exists" || fail "diagram-type-registry.md missing"

echo ""

# ===========================================
# Test 2: JSON Validity
# ===========================================
echo "=== 2. JSON Validity ==="

for f in "$BASE"/assets/schema-*.json "$BASE"/assets/examples/*.json; do
  name=$(basename "$f")
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
    pass "$name is valid JSON"
  else
    fail "$name is invalid JSON"
  fi
done

echo ""

# ===========================================
# Test 3: Schema Structure
# ===========================================
echo "=== 3. Schema Structure ==="

for type in architecture flowchart mindmap er sequence; do
  schema="$BASE/assets/schema-${type}.json"
  name="schema-${type}.json"

  # Check $schema field
  if python3 -c "import json; s=json.load(open('$schema')); assert s.get('\$schema','') == 'http://json-schema.org/draft-07/schema#'" 2>/dev/null; then
    pass "$name has JSON Schema draft-07"
  else
    fail "$name missing \$schema or wrong version"
  fi

  # Check required fields
  if python3 -c "import json; s=json.load(open('$schema')); assert 'required' in s; assert 'title' in s.get('required',[])" 2>/dev/null; then
    pass "$name requires 'title'"
  else
    fail "$name should require 'title'"
  fi

  # Check diagramType field
  if python3 -c "import json; s=json.load(open('$schema')); assert 'diagramType' in s.get('required',[])" 2>/dev/null; then
    pass "$name requires 'diagramType'"
  else
    fail "$name should require 'diagramType'"
  fi

  # Check style enum
  if python3 -c "
import json
s=json.load(open('$schema'))
style_enum = None
for key in ['style']:
  if key in s.get('properties',{}):
    style_enum = s['properties'][key].get('enum',[])
if style_enum and len(style_enum)==9:
  exit(0)
exit(1)
" 2>/dev/null; then
    pass "$name has 9 style options"
  else
    fail "$name should have 9 style options"
  fi

  # Check format enum
  if python3 -c "
import json
s=json.load(open('$schema'))
fmt = s.get('properties',{}).get('format',{}).get('enum',[])
if set(fmt) == {'html','svg','mermaid'}:
  exit(0)
exit(1)
" 2>/dev/null; then
    pass "$name has 3 format options (html/svg/mermaid)"
  else
    fail "$name should have format enum with html/svg/mermaid"
  fi
done

echo ""

# ===========================================
# Test 4: Example Files Match Their Schemas
# ===========================================
echo "=== 4. Example Files Match Schema ==="

for example in "$BASE"/assets/examples/*.json; do
  name=$(basename "$example")

  # Determine expected schema from filename or diagramType
  schema=$(python3 -c "
import json
e = json.load(open('$example'))
dt = e.get('diagramType', '')
if dt:
  print(f'schema-{dt}.json')
else:
  # Infer from filename prefix
  fn = '$name'
  if 'chrome' in fn or 'ai-platform' in fn or 'simple-webapp' in fn:
    print('schema-architecture.json')
  elif 'flowchart' in fn:
    print('schema-flowchart.json')
  elif 'mindmap' in fn:
    print('schema-mindmap.json')
  elif 'er-' in fn:
    print('schema-er.json')
  elif 'sequence-' in fn:
    print('schema-sequence.json')
  else:
    print('UNKNOWN')
" 2>/dev/null)

  if [ "$schema" = "UNKNOWN" ] || [ -z "$schema" ]; then
    fail "$name: cannot determine schema"
    continue
  fi

  # Validate required fields exist
  required_ok=$(python3 -c "
import json
e = json.load(open('$example'))
s = json.load(open('$BASE/assets/$schema'))
req = s.get('required', [])
missing = [r for r in req if r not in e]
if missing:
    print('MISSING: ' + ','.join(missing))
    exit(1)
# Check style is valid
if 'style' in e:
    valid_styles = s.get('properties',{}).get('style',{}).get('enum',[])
    if e['style'] not in valid_styles:
        print('INVALID STYLE: ' + e['style'])
        exit(1)
print('OK')
" 2>/dev/null)

  if [ "$required_ok" = "OK" ]; then
    pass "$name matches $schema"
  else
    fail "$name: $required_ok"
  fi

  # Check unique IDs (for architecture/flowchart types)
  ids_ok=$(python3 -c "
import json
e = json.load(open('$example'))
dt = e.get('diagramType','architecture')
ids = []
if dt == 'architecture':
    for layer in e.get('layers',[]):
        ids.append(layer.get('id',''))
        for c in layer.get('children',[]):
            ids.append(c.get('id',''))
elif dt == 'flowchart':
    for n in e.get('nodes',[]):
        ids.append(n.get('id',''))
elif dt == 'er':
    for ent in e.get('entities',[]):
        ids.append(ent.get('id',''))
elif dt == 'sequence':
    for a in e.get('actors',[]):
        ids.append(a.get('id',''))
# Check uniqueness
dupes = [x for x in ids if ids.count(x) > 1]
if dupes:
    print('DUPLICATE IDS: ' + ','.join(set(dupes)))
    exit(1)
if '' in ids:
    print('EMPTY ID found')
    exit(1)
print('OK')
" 2>/dev/null)

  if [ "$ids_ok" = "OK" ]; then
    pass "$name has unique non-empty IDs"
  else
    fail "$name: $ids_ok"
  fi
done

echo ""

# ===========================================
# Test 5: SKILL.md Content
# ===========================================
echo "=== 5. SKILL.md Content ==="

SKILL="$BASE/SKILL.md"

# Has YAML frontmatter
if head -1 "$SKILL" | grep -q "^---"; then
  pass "SKILL.md has YAML frontmatter"
else
  fail "SKILL.md missing YAML frontmatter"
fi

# Has 'name:' in frontmatter
if grep -q "^name:" "$SKILL"; then
  pass "SKILL.md has 'name' field"
else
  fail "SKILL.md missing 'name' field"
fi

# Has trigger keywords
if grep -q "架构图\|architecture\|flowchart\|mindmap\|sequence\|ER" "$SKILL"; then
  pass "SKILL.md has trigger keywords (EN+CN)"
else
  fail "SKILL.md missing trigger keywords"
fi

# References all 5 diagram types
for type in architecture flowchart mindmap er sequence; do
  if grep -q "$type" "$SKILL"; then
    pass "SKILL.md references '$type'"
  else
    fail "SKILL.md doesn't reference '$type'"
  fi
done

# References all 9 styles
for style in dark-professional hand-drawn light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream; do
  if grep -q "$style" "$SKILL"; then
    pass "SKILL.md references '$style'"
  else
    fail "SKILL.md doesn't reference '$style'"
  fi
done

# Has Two-Step Generation Process
if grep -q "Two-Step Generation" "$SKILL"; then
  pass "SKILL.md has Two-Step Generation section"
else
  fail "SKILL.md missing Two-Step Generation section"
fi

# Has Design Principles
if grep -q "Design Principles" "$SKILL"; then
  pass "SKILL.md has Design Principles"
else
  fail "SKILL.md missing Design Principles"
fi

# Has Quality Checklist
if grep -q "Quality Checklist" "$SKILL"; then
  pass "SKILL.md has Quality Checklist"
else
  fail "SKILL.md missing Quality Checklist"
fi

# Check line count (SKILL.md grows with features, just check it exists and is substantial)
lines=$(wc -l < "$SKILL")
if [ "$lines" -ge 100 ] && [ "$lines" -le 500 ]; then
  pass "SKILL.md is reasonable length ($lines lines)"
else
  fail "SKILL.md unusual length ($lines lines, expected 100-500)"
fi

echo ""

# ===========================================
# Test 6: Style References Content
# ===========================================
echo "=== 6. Style References Content ==="

for style in dark-professional hand-drawn light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream; do
  ref="$BASE/references/style-${style}.md"

  # Has Design Philosophy
  if grep -q "Design Philosophy" "$ref"; then
    pass "style-${style}.md has Design Philosophy"
  else
    fail "style-${style}.md missing Design Philosophy"
  fi

  # Has Prohibited rules
  if grep -q "Prohibited\|Do NOT" "$ref"; then
    pass "style-${style}.md has Prohibited/Do NOT rules"
  else
    fail "style-${style}.md missing Prohibited rules"
  fi

  # References template file
  if grep -q "template" "$ref"; then
    pass "style-${style}.md references template"
  else
    fail "style-${style}.md missing template reference"
  fi
done

echo ""

# ===========================================
# Test 7: Cross-References
# ===========================================
echo "=== 7. Cross-References ==="

# Check that files referenced in diagram-type-registry.md exist
REGISTRY="$BASE/references/diagram-type-registry.md"
if [ -f "$REGISTRY" ]; then
  # Extract file references (assets/* and references/*)
  for ref in $(grep -oE '(assets|references)/[a-zA-Z0-9_-]+\.(json|md|html)' "$REGISTRY" 2>/dev/null | sort -u); do
    if [ -f "$BASE/$ref" ]; then
      pass "Registry ref exists: $ref"
    else
      fail "Registry ref missing: $ref"
    fi
  done
else
  fail "diagram-type-registry.md not found"
fi

echo ""

# ===========================================
# Test 8: Design System
# ===========================================
echo "=== 8. Design System ==="

DESIGN="$BASE/references/design-system.md"
if [ -f "$DESIGN" ]; then
  grep -q "Icon System" "$DESIGN" && pass "design-system.md has Icon System" || fail "design-system.md missing Icon System"
  grep -q "icons-catalog" "$DESIGN" && pass "design-system.md references icons-catalog" || fail "design-system.md missing icons-catalog reference"
else
  fail "design-system.md not found"
fi

echo ""

# ===========================================
# Summary
# ===========================================
echo "====================================="
TOTAL=$((PASS + FAIL))
echo "  Results: ${GREEN}${PASS}${NC} passed, ${RED}${FAIL}${NC} failed out of ${TOTAL}"
if [ $FAIL -gt 0 ]; then
  echo ""
  echo "  Failures:"
  echo -e "$ERRORS"
  echo ""
  echo "  ${RED}SOME TESTS FAILED${NC}"
  exit 1
else
  echo "  ${GREEN}ALL TESTS PASSED${NC}"
fi
