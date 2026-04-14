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

# Resolve BASE relative to repo root (works locally and in CI)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="$REPO_ROOT/architecture-diagram/skills/architecture-diagram"

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

# 8 JSON schemas (5 original + 3 new)
for type in architecture flowchart mindmap er sequence gantt uml-class network; do
  [ -f "$BASE/assets/schema-${type}.json" ] && pass "schema-${type}.json exists" || fail "schema-${type}.json missing"
done

# 12 template HTML files (9 original + 3 new)
for style in dark sketch light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream notion material glassmorphism; do
  case $style in
    sketch) template="template-sketch" ;;
    dark) template="template-dark" ;;
    *) template="template-${style}" ;;
  esac
  [ -f "$BASE/assets/${template}.html" ] && pass "${template}.html exists" || fail "${template}.html missing"
done

# 12 style reference files (9 original + 3 new)
for style in dark-professional hand-drawn light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream notion material glassmorphism; do
  [ -f "$BASE/references/style-${style}.md" ] && pass "style-${style}.md exists" || fail "style-${style}.md missing"
done

# 8 diagram reference files (5 original + 3 new)
for type in architecture flowchart mindmap er sequence gantt uml-class network; do
  [ -f "$BASE/references/diagram-${type}.md" ] && pass "diagram-${type}.md exists" || fail "diagram-${type}.md missing"
done

# 8 layout reference files
[ -f "$BASE/references/layout-rules.md" ] && pass "layout-rules.md exists" || fail "layout-rules.md missing"
for type in flowchart mindmap er sequence gantt uml-class network; do
  [ -f "$BASE/references/layout-${type}.md" ] && pass "layout-${type}.md exists" || fail "layout-${type}.md missing"
done

# 7 component reference files (flowchart mindmap er sequence gantt uml-class network)
for type in flowchart mindmap er sequence gantt uml-class network; do
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

for type in architecture flowchart mindmap er sequence gantt uml-class network; do
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
if style_enum and len(style_enum)==12:
  exit(0)
exit(1)
" 2>/dev/null; then
    pass "$name has 12 style options"
  else
    fail "$name should have 12 style options"
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

# References all 12 styles
for style in dark-professional hand-drawn light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream notion material glassmorphism; do
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
# Test 9: data-chart Skill — File Structure
# ===========================================
echo "=== 9. data-chart Skill — File Structure ==="

CHART_BASE="$REPO_ROOT/architecture-diagram/skills/data-chart"

[ -f "$CHART_BASE/SKILL.md" ] && pass "data-chart/SKILL.md exists" || fail "data-chart/SKILL.md missing"
[ -f "$CHART_BASE/assets/schema-bar.json" ] && pass "data-chart schema-bar.json exists" || fail "data-chart schema-bar.json missing"
[ -f "$CHART_BASE/references/axis-and-grid.md" ] && pass "data-chart axis-and-grid.md exists" || fail "data-chart axis-and-grid.md missing"
[ -f "$CHART_BASE/references/color-palettes.md" ] && pass "data-chart color-palettes.md exists" || fail "data-chart color-palettes.md missing"
[ -f "$CHART_BASE/references/render-bar.md" ] && pass "data-chart render-bar.md exists" || fail "data-chart render-bar.md missing"
[ -f "$CHART_BASE/assets/examples/quarterly-revenue.json" ] && pass "data-chart example JSON exists" || fail "data-chart example JSON missing"
[ -f "$CHART_BASE/assets/examples/quarterly-revenue.html" ] && pass "data-chart example HTML exists" || fail "data-chart example HTML missing"

echo ""

# ===========================================
# Test 10: data-chart Schema Validation
# ===========================================
echo "=== 10. data-chart Schema Validation ==="

BAR_SCHEMA="$CHART_BASE/assets/schema-bar.json"

# Valid JSON
if python3 -c "import json; json.load(open('$BAR_SCHEMA'))" 2>/dev/null; then
  pass "schema-bar.json is valid JSON"
else
  fail "schema-bar.json is invalid JSON"
fi

# Has JSON Schema draft-07
if python3 -c "import json; s=json.load(open('$BAR_SCHEMA')); assert s.get('\$schema','') == 'http://json-schema.org/draft-07/schema#'" 2>/dev/null; then
  pass "schema-bar.json has JSON Schema draft-07"
else
  fail "schema-bar.json missing \$schema draft-07"
fi

# Requires diagramType and title and series
if python3 -c "import json; s=json.load(open('$BAR_SCHEMA')); req=s.get('required',[]); assert 'diagramType' in req and 'title' in req and 'series' in req" 2>/dev/null; then
  pass "schema-bar.json requires diagramType, title, series"
else
  fail "schema-bar.json missing required fields"
fi

# additionalProperties: false on root
if python3 -c "import json; s=json.load(open('$BAR_SCHEMA')); assert s.get('additionalProperties') == False" 2>/dev/null; then
  pass "schema-bar.json root has additionalProperties: false"
else
  fail "schema-bar.json root missing additionalProperties: false"
fi

# All $defs objects have additionalProperties: false
ALL_AP_FALSE=$(python3 -c "
import json
s = json.load(open('$BAR_SCHEMA'))
defs = s.get('\$defs', {})
bad = []
for name, defn in defs.items():
    if defn.get('type') == 'object' and defn.get('additionalProperties') is not False:
        bad.append(name)
if bad:
    print(','.join(bad))
    exit(1)
print('OK')
" 2>/dev/null)
if [ "$ALL_AP_FALSE" = "OK" ]; then
  pass "schema-bar.json all \$defs objects have additionalProperties: false"
else
  fail "schema-bar.json \$defs missing additionalProperties: false in: $ALL_AP_FALSE"
fi

# Color fields have pattern
COLOR_PATTERN_OK=$(python3 << 'PYEOF'
import json
s = json.load(open('$BAR_SCHEMA'))
defs = s.get('$defs', {})
# Check colorsOverride
co = defs.get('colorsOverride', {}).get('properties', {})
hex_pat = '^#[0-9a-fA-F]{6}$'
for key in ['primary', 'secondary', 'accent', 'background', 'text']:
    if key in co and co[key].get('pattern') != hex_pat:
        print(f'colorsOverride.{key} missing pattern')
        exit(1)
# Check seriesItem.color
si = defs.get('seriesItem', {}).get('properties', {})
if 'color' in si and si['color'].get('pattern') != hex_pat:
    print('seriesItem.color missing pattern')
    exit(1)
print('OK')
PYEOF
)
if [ "$COLOR_PATTERN_OK" = "OK" ]; then
  pass "schema-bar.json color fields have hex pattern"
else
  fail "schema-bar.json color fields missing hex pattern: $COLOR_PATTERN_OK"
fi

# maxLength on string fields
MAXLENGTH_OK=$(python3 -c "
import json
s = json.load(open('$BAR_SCHEMA'))
checks = [
    ('title', s['properties']['title']),
    ('subtitle', s['properties']['subtitle']),
]
defs = s.get('\$defs', {})
checks += [
    ('seriesItem.name', defs['seriesItem']['properties']['name']),
    ('dataPoint.label', defs['dataPoint']['properties']['label']),
    ('axisConfig.label', defs['axisConfig']['properties']['label']),
]
bad = []
for name, field in checks:
    if 'maxLength' not in field:
        bad.append(name)
if bad:
    print(','.join(bad))
    exit(1)
print('OK')
" 2>/dev/null)
if [ "$MAXLENGTH_OK" = "OK" ]; then
  pass "schema-bar.json string fields have maxLength"
else
  fail "schema-bar.json missing maxLength on: $MAXLENGTH_OK"
fi

# Array size constraints
ARRAY_CONSTRAINTS_OK=$(python3 -c "
import json
s = json.load(open('$BAR_SCHEMA'))
defs = s.get('\$defs', {})
checks = [
    ('series', s['properties']['series'], 1, 8),
    ('seriesItem.data', defs['seriesItem']['properties']['data'], 2, 30),
    ('axisConfig.ticks', defs['axisConfig']['properties']['ticks'], 2, 10),
]
bad = []
for name, field, minE, maxE in checks:
    if field.get('minItems') != minE:
        bad.append(f'{name}.minItems')
    if field.get('maxItems') != maxE:
        bad.append(f'{name}.maxItems')
if bad:
    print(','.join(bad))
    exit(1)
print('OK')
" 2>/dev/null)
if [ "$ARRAY_CONSTRAINTS_OK" = "OK" ]; then
  pass "schema-bar.json arrays have minItems/maxItems"
else
  fail "schema-bar.json array constraints missing: $ARRAY_CONSTRAINTS_OK"
fi

echo ""

# ===========================================
# Test 11: data-chart Example Validation
# ===========================================
echo "=== 11. data-chart Example Validation ==="

EXAMPLE="$CHART_BASE/assets/examples/quarterly-revenue.json"

# Valid JSON
if python3 -c "import json; json.load(open('$EXAMPLE'))" 2>/dev/null; then
  pass "quarterly-revenue.json is valid JSON"
else
  fail "quarterly-revenue.json is invalid JSON"
fi

# diagramType = bar
if python3 -c "import json; e=json.load(open('$EXAMPLE')); assert e['diagramType'] == 'bar'" 2>/dev/null; then
  pass "quarterly-revenue.json diagramType = bar"
else
  fail "quarterly-revenue.json wrong diagramType"
fi

# Has required fields
if python3 -c "
import json
e = json.load(open('$EXAMPLE'))
for f in ['diagramType', 'title', 'series']:
    assert f in e, f'missing {f}'
assert len(e['series']) >= 1
assert len(e['series'][0]['data']) >= 2
" 2>/dev/null; then
  pass "quarterly-revenue.json has required fields and data"
else
  fail "quarterly-revenue.json missing required fields"
fi

# ticks match Nice Numbers for [120,150,180,200]
if python3 -c "
import json
e = json.load(open('$EXAMPLE'))
ticks = e.get('axis',{}).get('y',{}).get('ticks',[])
assert ticks == [0, 50, 100, 150, 200], f'wrong ticks: {ticks}'
" 2>/dev/null; then
  pass "quarterly-revenue.json ticks = [0,50,100,150,200]"
else
  fail "quarterly-revenue.json ticks don't match Nice Numbers"
fi

# Validate against schema (structural check)
SCHEMA_VALIDATE=$(python3 -c "
import json

schema = json.load(open('$BAR_SCHEMA'))
data = json.load(open('$EXAMPLE'))

# Check all required fields present
for f in schema.get('required', []):
    if f not in data:
        print(f'missing required: {f}')
        exit(1)

# Check style enum
valid_styles = schema['properties']['style']['enum']  # may be \$ref
# Resolve style enum from \$defs if needed
sp = schema['properties'].get('style', {})
if '\$ref' in sp:
    ref_name = sp['\$ref'].split('/')[-1]
    valid_styles = schema['\$defs'][ref_name]['enum']
elif 'enum' in sp:
    valid_styles = sp['enum']
else:
    valid_styles = []

if data.get('style') and data['style'] not in valid_styles:
    print(f'invalid style: {data[\"style\"]}')
    exit(1)

# Check series data
for s in data['series']:
    if len(s['data']) < 2:
        print('series data < 2 items')
        exit(1)

print('OK')
" 2>/dev/null)
if [ "$SCHEMA_VALIDATE" = "OK" ]; then
  pass "quarterly-revenue.json validates against schema-bar.json"
else
  fail "quarterly-revenue.json schema validation: $SCHEMA_VALIDATE"
fi

echo ""

# ===========================================
# Test 12: data-chart Example HTML
# ===========================================
echo "=== 12. data-chart Example HTML ==="

EXAMPLE_HTML="$CHART_BASE/assets/examples/quarterly-revenue.html"

# Has DOCTYPE
grep -q "<!DOCTYPE html>" "$EXAMPLE_HTML" && pass "HTML has DOCTYPE" || fail "HTML missing DOCTYPE"

# Has <svg with xmlns
grep -q '<svg.*xmlns="http://www.w3.org/2000/svg"' "$EXAMPLE_HTML" && pass "HTML has SVG with xmlns" || fail "HTML missing SVG xmlns"

# Has foreignObject with xhtml namespace
grep -q 'xmlns="http://www.w3.org/1999/xhtml"' "$EXAMPLE_HTML" && pass "HTML foreignObject has xhtml xmlns" || fail "HTML foreignObject missing xhtml xmlns"

# Has chart CSS classes
grep -q 'class="axis-line"' "$EXAMPLE_HTML" && pass "HTML has axis-line CSS class" || fail "HTML missing axis-line"
grep -q 'class="grid-line"' "$EXAMPLE_HTML" && pass "HTML has grid-line CSS class" || fail "HTML missing grid-line"
grep -q 'class="bar"' "$EXAMPLE_HTML" && pass "HTML has bar CSS class" || fail "HTML missing bar"
grep -q 'class="tick-label"' "$EXAMPLE_HTML" && pass "HTML has tick-label CSS class" || fail "HTML missing tick-label"

# Has bar fill color from Palette B
grep -q 'fill="#6366f1"' "$EXAMPLE_HTML" && pass "HTML bar uses Palette B color (#6366f1)" || fail "HTML bar wrong fill color"

# Has 4 bars
BAR_COUNT=$(grep -c 'class="bar"' "$EXAMPLE_HTML")
if [ "$BAR_COUNT" -eq 4 ]; then
  pass "HTML has exactly 4 bars"
else
  fail "HTML has $BAR_COUNT bars, expected 4"
fi

# Has grid lines (should have 4 for ticks 50,100,150,200)
GRID_COUNT=$(grep -c 'class="grid-line"' "$EXAMPLE_HTML")
if [ "$GRID_COUNT" -ge 3 ]; then
  pass "HTML has $GRID_COUNT grid lines"
else
  fail "HTML has only $GRID_COUNT grid lines, expected 4"
fi

# No JavaScript
if grep -q '<script' "$EXAMPLE_HTML"; then
  fail "HTML contains <script> tags (no JS allowed)"
else
  pass "HTML has no JavaScript"
fi

echo ""

# ===========================================
# Test 13: data-chart SKILL.md Content
# ===========================================
echo "=== 13. data-chart SKILL.md Content ==="

CHART_SKILL="$CHART_BASE/SKILL.md"

# Has YAML frontmatter
head -1 "$CHART_SKILL" | grep -q "^---" && pass "data-chart SKILL.md has YAML frontmatter" || fail "data-chart SKILL.md missing YAML frontmatter"

# Has name field
grep -q "^name: data-chart" "$CHART_SKILL" && pass "data-chart SKILL.md has correct name" || fail "data-chart SKILL.md wrong/missing name"

# Has chart trigger keywords
grep -q "bar chart\|柱状图\|pie chart\|line chart" "$CHART_SKILL" && pass "data-chart SKILL.md has trigger keywords" || fail "data-chart SKILL.md missing trigger keywords"

# References schema files
grep -q "schema-bar.json" "$CHART_SKILL" && pass "data-chart SKILL.md references schema-bar.json" || fail "data-chart SKILL.md missing schema-bar.json reference"

# References render references
grep -q "render-bar.md" "$CHART_SKILL" && pass "data-chart SKILL.md references render-bar.md" || fail "data-chart SKILL.md missing render-bar.md reference"

# Has Two-Step process
grep -q "Two-Step Generation" "$CHART_SKILL" && pass "data-chart SKILL.md has Two-Step Generation" || fail "data-chart SKILL.md missing Two-Step Generation"

# Has Quality Checklist
grep -q "Quality Checklist" "$CHART_SKILL" && pass "data-chart SKILL.md has Quality Checklist" || fail "data-chart SKILL.md missing Quality Checklist"

echo ""

# ===========================================
# Test 14: Template Chart CSS Classes
# ===========================================
echo "=== 14. Template Chart CSS Classes ==="

for style in dark sketch light-corporate cyberpunk-neon blueprint warm-cozy minimalist terminal-retro pastel-dream notion material glassmorphism; do
  case $style in
    sketch) template="template-sketch" ;;
    dark) template="template-dark" ;;
    *) template="template-${style}" ;;
  esac
  tmpl="$BASE/assets/${template}.html"

  # Has chart CSS section
  grep -q "Chart classes" "$tmpl" && pass "${template}.html has chart CSS section" || fail "${template}.html missing chart CSS section"

  # Has required chart CSS classes
  grep -q '\.axis-line' "$tmpl" && pass "${template}.html has .axis-line" || fail "${template}.html missing .axis-line"
  grep -q '\.grid-line' "$tmpl" && pass "${template}.html has .grid-line" || fail "${template}.html missing .grid-line"
  grep -q '\.bar' "$tmpl" && pass "${template}.html has .bar" || fail "${template}.html missing .bar"
  grep -q '\.tick-label' "$tmpl" && pass "${template}.html has .tick-label" || fail "${template}.html missing .tick-label"
done

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
