# CLAUDE.md — gmdiagram

## Project Overview

`gmdiagram` is a Claude Code / Codex plugin marketplace that generates publication-quality diagrams and data charts from natural language. The marketplace includes two independent plugins:

- **gm-architecture**: Generates architecture diagrams, flowcharts, mind maps, ER diagrams, sequence diagrams, Gantt charts, UML class diagrams, and network topology diagrams
- **gm-data-chart**: Generates data visualization charts (bar, pie, line, area, scatter, radar, funnel, bubble, table)

Both plugins produce single-file HTML with inline SVG and embedded CSS — no JavaScript required.

- **Repository**: https://github.com/ZeroZ-lab/gmdiagram
- **Author**: zhengjianqiao
- **License**: MIT
- **Versions**: Marketplace `0.7.0`, Plugin `0.7.0`

## Repository Structure

```
gmdiagram/
├── .claude-plugin/marketplace.json          # Claude Code marketplace definition
├── .agents/plugins/marketplace.json         # Codex marketplace definition
├── gm-architecture/                         # Plugin 1: Architecture diagrams
│   ├── .claude-plugin/plugin.json           # Claude plugin manifest
│   ├── .codex-plugin/plugin.json            # Codex plugin manifest
│   ├── README.md                            # Plugin overview
│   └── skills/
│       └── gm-architecture/
│           ├── SKILL.md                     # Skill instructions
│           ├── README.md                    # Full user documentation
│           ├── references/                  # Technical reference docs
│           ├── assets/
│           │   ├── schema-*.json            # JSON schemas per diagram type
│           │   ├── template-*.html          # HTML templates per visual style
│           │   └── examples/                # Example diagrams
│           └── scripts/
│               ├── export.sh                # PNG/PDF export script
│               └── package.json             # resvg-js dependency
├── gm-data-chart/                           # Plugin 2: Data visualization charts
│   ├── .claude-plugin/plugin.json           # Claude plugin manifest
│   ├── .codex-plugin/plugin.json            # Codex plugin manifest
│   ├── README.md                            # Plugin overview
│   └── skills/
│       └── gm-data-chart/
│           ├── SKILL.md                     # Skill instructions
│           ├── references/                  # Chart render rules, palettes, axis rules
│           ├── assets/
│           │   ├── schema-*.json            # Chart JSON schemas
│           │   ├── template-*.html          # HTML templates (copied from gm-architecture)
│           │   └── examples/                # Example charts
│           └── scripts/
│               └── export.sh -> ../../gm-architecture/skills/gm-architecture/scripts/export.sh
├── docs/SPEC.md                             # Product specification (Chinese)
└── tasks/                                   # Task tracking and test outputs
```

## Architecture & Design

### Two-Step Generation Process

ALL diagram generation follows exactly two steps. Never skip to output directly.

1. **Step 1 — JSON Schema**: Extract structure from user's natural language description into the typed JSON schema (`assets/schema-{type}.json`)
2. **Step 2 — Render Output**: Use the JSON + layout rules + style template to produce the final file

### Supported Diagram Types

| Type | Schema File | Reference | Trigger Keywords |
|------|------------|-----------|-----------------|
| `architecture` | `schema-architecture.json` | `diagram-architecture.md` | system, layered, infrastructure, 架构图 |
| `flowchart` | `schema-flowchart.json` | `diagram-flowchart.md` | flow, decision, process, 流程图 |
| `mindmap` | `schema-mindmap.json` | `diagram-mindmap.md` | brainstorm, hierarchy, 思维导图 |
| `er` | `schema-er.json` | `diagram-er.md` | database, entity, schema, ER图 |
| `sequence` | `schema-sequence.json` | `diagram-sequence.md` | API flow, message, interaction, 时序图 |
| `gantt` | `schema-gantt.json` | `diagram-gantt.md` | timeline, schedule, milestone, 甘特图 |
| `uml-class` | `schema-uml-class.json` | `diagram-uml-class.md` | UML, class diagram, OOP, 类图 |
| `network` | `schema-network.json` | `diagram-network.md` | topology, subnet, 网络拓扑 |
| `card` | `schema-card.json` | `diagram-card.md` | social card, knowledge card, 知识卡片, 对比卡片, 引用卡片, 排行卡片 |

### Supported Chart Types (data-chart skill)

| Type | Schema File | Render Reference | Trigger Keywords |
|------|------------|-----------------|-----------------|
| `bar` | `schema-bar.json` | `render-bar.md` | bar chart, column chart, 柱状图, 条形图 |
| `pie` | `schema-pie.json` | `render-pie.md` | pie chart, donut chart, 饼图, 环形图 |
| `line` | `schema-line.json` | `render-line.md` | line chart, 折线图 |
| `area` | `schema-area.json` | `render-area.md` | area chart, stacked area, 面积图, 堆叠面积图 |
| `scatter` | `schema-scatter.json` | `render-scatter.md` | scatter plot, 散点图 |
| `radar` | `schema-radar.json` | `render-radar.md` | radar chart, spider chart, 雷达图 |
| `funnel` | `schema-funnel.json` | `render-funnel.md` | funnel chart, 漏斗图 |
| `bubble` | `schema-bubble.json` | `render-bubble.md` | bubble chart, 气泡图 |
| `table` | `schema-table.json` | `render-table.md` | data table, comparison table, 数据表, 对比表 |

### Visual Styles (12)

`dark-professional` (default), `hand-drawn`, `light-corporate`, `cyberpunk-neon`, `blueprint`, `warm-cozy`, `minimalist`, `terminal-retro`, `pastel-dream`, `notion`, `material`, `glassmorphism`

Each style has a reference file (`references/style-{name}.md`) and an HTML template (`assets/template-{name}.html`).

### Output Formats (4)

- **HTML** (default): Single file, inline SVG + embedded CSS, zero JS
- **SVG**: Standalone `.svg` file
- **Mermaid**: Text syntax for GitHub/Notion embedding
- **PNG/PDF**: Via `scripts/export.sh` (requires Node.js for PNG, `rsvg-convert` for PDF)

## Code Conventions

- **No JavaScript** in generated HTML/SVG output
- **Escape all user text**: HTML-entity-encode `<`, `>`, `&`, `"`, `'` before inserting into SVG/HTML
- **Component IDs**: kebab-case, unique within a diagram
- **Layer heights**: Exactly `LAYER_H_BADGE` (116px) or `LAYER_H_SIMPLE` (101px) — never custom heights
- **Layer gaps**: Exactly 50px between adjacent layers, never overlapping
- **foreignObject**: Root HTML element must include `xmlns="http://www.w3.org/1999/xhtml"`
- **Connection labels**: `text-anchor="middle" dominant-baseline="central"`
- **Use CSS classes** from templates (`.module`, `.type-X`, `.module-label`) — don't invent new ones
- **Color system**: Use the defined semantic color palette only — don't create custom colors

## Commands

```bash
# PNG export (requires Node.js 18+, auto-installs @resvg/resvg-js)
./gm-architecture/skills/gm-architecture/scripts/export.sh input.html --format png

# PDF export (requires: brew install librsvg)
./gm-architecture/skills/gm-architecture/scripts/export.sh input.html --format pdf

# Install export dependencies
cd gm-architecture/skills/gm-architecture/scripts && npm install
```

## Version Management

**Every commit MUST bump the version number.** Follow SemVer rules:

| Change Type | Version Bump | Example |
|-------------|-------------|---------|
| Bug fix, typo, small tweak | `patch +1` | `0.1.0` → `0.1.1` |
| New feature, new diagram type/style, new template | `minor +1` | `0.1.0` → `0.3.0` |
| Breaking change to schema, template API, or output format | `major +1` | `0.1.0` → `1.0.0` |

Files to update on every version bump (keep all in sync):

1. `CLAUDE.md` — update the version line at the top
2. `README.md` — update the Version section
3. `.claude-plugin/marketplace.json` — update `version` and plugin `version`
4. `.agents/plugins/marketplace.json` — update `version`
5. `gm-architecture/.claude-plugin/plugin.json` — update `version`
6. `gm-architecture/.codex-plugin/plugin.json` — update `version`
7. `gm-data-chart/.claude-plugin/plugin.json` — update `version`
8. `gm-data-chart/.codex-plugin/plugin.json` — update `version`
9. `docs/SPEC.md` — update the version section

When creating a commit, include the version bump in the same commit as the changes.

## Boundaries

### Always Do
- **Bump version on every commit** — no exceptions
- Generate JSON Schema first, then render output (two-step process)
- Use per-style template files as the starting structure
- Output single-file results that work without a server
- Validate JSON against the diagram type's schema before rendering
- Follow layout rules from `references/layout-{type}.md` files

### Ask First
- When the requested diagram type is not in the supported list
- When the user wants custom colors or branding outside the design system
- When the requested output format is not supported

### Never Do
- Generate output that requires JavaScript to view
- Build an interactive editor or WYSIWYG tool
- Introduce framework dependencies (React, D3, etc.) into generated output
- Let LLM guess absolute coordinates — must use CSS layout engine via foreignObject
- Skip the JSON schema step and go directly to output generation
