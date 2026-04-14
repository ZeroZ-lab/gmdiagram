---
name: data-chart
description: >
  Generate data visualization charts from natural language descriptions.
  Creates single-file HTML with inline SVG that can be opened in any browser.
  Use this skill whenever the user asks to create, draw, or generate:
  bar chart, column chart, 柱状图, 条形图, pie chart, donut chart, 饼图, 环形图,
  line chart, area chart, 折线图, 面积图, data visualization, chart,
  数据可视化, 图表, or wants to visualize data, compare values, show trends.
  Supports 3 chart types and 12 visual styles.
  Supports 4 output formats: html, svg, mermaid, png/pdf (via export script).
---

# gmdiagram — Data Chart Skill

## What This Skill Does

Generate publication-quality data visualization charts as standalone files. The output can be:
- **HTML**: Single `.html` file with inline SVG and embedded CSS (default, no JavaScript)
- **SVG**: Standalone `.svg` file
- **Mermaid**: Text syntax (limited chart support, see Mermaid rules)
- **PNG/PDF**: Via the export script at `../architecture-diagram/scripts/export.sh`

## Interactive Selection

When the user's request does NOT already specify all three choices (chart type, style, output format), use the `AskUserQuestion` tool to let the user choose.

**Important**: `AskUserQuestion` supports at most **4 options per question** and **4 questions per call**.

### Selection Strategy

For each dimension, follow this logic:

1. **Can the choice be inferred from the user's description?** → Skip asking, use the inferred value directly.
2. **Does the user explicitly state it?** → Skip asking, use the stated value.
3. **Still ambiguous?** → Ask via `AskUserQuestion`.

### Question 1 — Chart Type (ask only if ambiguous)

The user's description usually makes the type obvious. Only ask when multiple types could fit.

```
question: "Which chart type fits your needs?"
header: "Type"
options:
  - label: "Bar Chart"
    description: "Compare categories with bars (column chart)"
  - label: "Pie Chart"
    description: "Show proportions of a whole"
  - label: "Line Chart"
    description: "Show trends over time"
```

### Question 2 — Visual Style

Use the same 3-family approach as architecture-diagram:

```
First ask:
  "Which style family?" → Dark / Light+Clean / Creative

Then drill down within the family.
```

Infer from context when possible: technical content → dark, business → light-corporate, creative → cyberpunk/pastel.

### Question 3 — Output Format

Default is HTML. Only ask if the user mentions a specific use case (GitHub → Mermaid, print → SVG/PDF).

## Two-Step Generation Process

ALL chart generation follows exactly two steps. Never skip to output directly.

### Step 1 — Extract to JSON Schema

Extract data from the user's natural language description into the typed JSON schema for the chosen chart type.

**Schema files:**
| Chart Type | Schema File |
|---|---|
| bar | `assets/schema-bar.json` |
| pie | `assets/schema-pie.json` (Phase 2) |
| line | `assets/schema-line.json` (Phase 3) |

**Critical: Nice Numbers algorithm runs in this step.**

Read `references/axis-and-grid.md` for the full algorithm. Compute Y-axis ticks and store them in `axis.y.ticks`. This avoids complex math in Step 2.

**Data extraction rules:**
- Extract numeric values and labels from user text
- Infer series names when multiple data sets are mentioned
- When user provides percentages, store as raw values (not pre-multiplied)
- When user says "compare X and Y", infer grouped bar chart with 2 series
- All string fields have maxLength constraints — truncate if necessary with a note to the user

**Validation:**
- Bar/Line: `series` max 8, `data` per series max 30. If exceeded, **must** ask user to simplify.
- Pie: `data` max 12. If exceeded, suggest merging smallest items into "Others".
- All `value` fields must be finite numbers (no NaN, Infinity).
- All `color` fields must match `^#[0-9a-fA-F]{6}$`.

### Step 2 — Render Output

Read the corresponding render reference and template, then generate SVG wrapped in HTML.

**Render references:**
| Chart Type | Render Reference |
|---|---|
| bar | `references/render-bar.md` |
| pie | `references/render-pie.md` (Phase 2) |
| line | `references/render-line.md` (Phase 3) |

**Shared references** (read for all chart types):
- `references/axis-and-grid.md` — axis, grid, tick rendering
- `references/color-palettes.md` — palette selection and color assignment

**Template:** Use `../architecture-diagram/assets/template-{style}.html` (shared templates with chart CSS classes already added).

**Rendering approach — Hybrid Mode:**
- Data marks (bars, arcs, lines, dots): pure SVG native elements (`<rect>`, `<path>`, `<circle>`, `<line>`)
- Text (labels, legend, axis titles): `foreignObject` + CSS layout
- All `foreignObject` root elements must include `xmlns="http://www.w3.org/1999/xhtml"`

## Chart Type Reference

| Type | Trigger Keywords | Status |
|------|-----------------|--------|
| **bar** | bar chart, column chart, 柱状图, 条形图, 对比 | Available |
| **pie** | pie chart, donut chart, 饼图, 环形图, 占比 | Phase 2 |
| **line** | line chart, area chart, 折线图, 面积图, 趋势 | Phase 3 |

**Phase 1 limitation:** If the user requests pie or line chart, inform them that only bar chart is currently available, and offer to create a bar chart instead.

## Data Extraction Rules

- Extract numbers and labels directly from the user's description
- Support formats like "Q1=120万, Q2=150万" or "Chrome 65%, Safari 19%"
- Remove units from values (store "120" not "120万"), put units in `axis.y.label` or `subtitle`
- When multiple series are mentioned, create separate series objects
- Handle percentage input: if all values sum to ~100, they're percentages; store as-is

## Quality Checklist

Before finalizing any chart output, verify ALL of the following:

### Data & Schema
- [ ] JSON validates against the chart type's schema file
- [ ] `axis.y.ticks` uses nice numbers (no awkward decimals unless data has decimals)
- [ ] All values are finite numbers (no NaN or Infinity)
- [ ] Array sizes within limits (series ≤ 8, data ≤ 30, pie data ≤ 12)

### Visual
- [ ] Bar width and spacing visually balanced
- [ ] Text labels readable (≥ 11px, contrast ≥ 3:1 against background)
- [ ] ViewBox fits content — no clipping, no more than 20% whitespace
- [ ] Legend matches actual data series/colors
- [ ] Grid lines don't overlap with axis line

### Technical
- [ ] All `foreignObject` root elements have `xmlns="http://www.w3.org/1999/xhtml"`
- [ ] All user text is HTML-entity-escaped (`<`, `>`, `&` in text content; additionally `"` and control chars in attribute values)
- [ ] No user text in element name or attribute name positions
- [ ] Colors in `#rrggbb` format only — no `rgb()`, `rgba()`, named colors, `url()`
- [ ] No JavaScript in output
- [ ] ViewBox width and height are integers (no decimals)
- [ ] CSS classes match template definitions (`.axis-line`, `.grid-line`, `.bar`, `.tick-label`, etc.)

### Bar Chart Specific
- [ ] Bars are proportional to data values
- [ ] Y-axis ticks evenly spaced
- [ ] X-axis labels centered under each bar/group
- [ ] Negative values handled correctly (bars extend below baseline)

## Iteration Workflow

Follow-up requests to modify an existing chart:

1. **Modify existing JSON** — add/remove data points, change series
2. **Re-render** from modified JSON
3. **Style change** — re-render with different template (keep JSON unchanged)
4. **Format change** — re-export to different output format

Common modifications:
- "Add another series" → add to `series` array, re-render
- "Change to horizontal" → set `direction: "horizontal"`, re-render
- "Stack the bars" → set `variant: "stacked"`, re-render
- "Switch to hand-drawn style" → change `style`, re-render with different template
