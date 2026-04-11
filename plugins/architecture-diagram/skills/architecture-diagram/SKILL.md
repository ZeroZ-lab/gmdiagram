---
name: architecture-diagram
description: >
  Generate professional architecture diagrams from system descriptions.
  Creates single-file HTML with inline SVG that can be opened in any browser.
  Use this skill whenever the user asks to create, draw, or generate:
  architecture diagrams, system diagrams, infrastructure diagrams, layered architecture,
  component diagrams, platform capability maps, process architecture, microservice architecture,
  system design diagrams, architecture visualization, tech stack diagrams,
  flowchart, flow chart, decision tree, process flow,
  mind map, mindmap, brainstorm, concept map,
  ER diagram, entity relationship, database schema, data model,
  sequence diagram, interaction diagram, message flow, API flow, protocol flow,
  分层架构图, 系统架构图, 架构图, 流程图, 思维导图, ER图, 序列图, 时序图,
  or wants to visualize how a system works.
  Supports 5 diagram types and 6 visual styles: dark-professional, hand-drawn, light-corporate, cyberpunk-neon, blueprint, warm-cozy.
  Supports 4 output formats: html, svg, mermaid, png/pdf (via export script).
---

# gmdiagram — Architecture Diagram Skill

## What This Skill Does

Generate publication-quality diagrams as standalone files. The output can be:
- **HTML**: Single `.html` file with inline SVG and embedded CSS (default, no JavaScript)
- **SVG**: Standalone `.svg` file
- **Mermaid**: Mermaid text syntax (paste into GitHub, Notion, etc.)
- **PNG/PDF**: Via the export script at `scripts/export.sh`

## Diagram Type Selection

When the user describes a system, determine the diagram type:

| User Intent | Diagram Type | Reference File |
|---|---|---|
| System layers, tiers, services, infrastructure, platform | `architecture` | `references/diagram-architecture.md` |
| Process flow, decision tree, algorithm, branching logic | `flowchart` | `references/diagram-flowchart.md` |
| Brainstorm, topic hierarchy, feature tree, learning roadmap | `mindmap` | `references/diagram-mindmap.md` |
| Database tables, entities, relationships, data model | `er` | `references/diagram-er.md` |
| Message flow, API calls, protocol, interaction between actors | `sequence` | `references/diagram-sequence.md` |

If unsure, default to `architecture`. Read the diagram-type-registry at `references/diagram-type-registry.md` for detailed trigger keywords.

## Two-Step Generation Process

ALWAYS follow these two steps in order. Never skip to output directly.

### Step 1: Generate JSON Schema

Read the user's description and extract structure into the JSON schema for the selected diagram type. Each type has its own schema file in `assets/`:

| Diagram Type | Schema File |
|---|---|
| `architecture` | `assets/schema-architecture.json` |
| `flowchart` | `assets/schema-flowchart.json` |
| `mindmap` | `assets/schema-mindmap.json` |
| `er` | `assets/schema-er.json` |
| `sequence` | `assets/schema-sequence.json` |

Key rules across all types:
- Every component gets a unique `id` (kebab-case)
- Use semantic `type` values as defined in each schema
- If the user doesn't specify a style, use `dark-professional`
- If the user doesn't specify a format, use `html`
- Components can reference icons via the `"icon"` field (see `references/icons-catalog.md`)

Output the JSON first, then proceed to Step 2.

### Step 2: Generate Output

Read the diagram-type reference file for generation instructions:

1. **Choose template**: Based on the `style` field, read the corresponding style reference and template:
   - `dark-professional` → `references/style-dark-professional.md` → `assets/template-dark.html`
   - `hand-drawn` → `references/style-hand-drawn.md` → `assets/template-sketch.html`
   - `light-corporate` → `references/style-light-corporate.md` → `assets/template-light-corporate.html`
   - `cyberpunk-neon` → `references/style-cyberpunk-neon.md` → `assets/template-cyberpunk-neon.html`
   - `blueprint` → `references/style-blueprint.md` → `assets/template-blueprint.html`
   - `warm-cozy` → `references/style-warm-cozy.md` → `assets/template-warm-cozy.html`

2. **Compute layout**: Follow the coordinate calculation rules in the diagram-type-specific layout file.

3. **Build SVG**: Use the component SVG snippets from the diagram-type-specific components file.

4. **Wrap in HTML** (if format=html): Use the corresponding template file as the starting structure.

For other formats:
- **SVG**: Follow `references/output-svg.md` — extract standalone SVG
- **Mermaid**: Follow `references/output-mermaid.md` — transform JSON to Mermaid text
- **PNG/PDF**: First generate HTML or SVG, then run `scripts/export.sh` (see `references/output-png-pdf.md`)

## Design Principles

1. **Diagrams should argue, not just display** — every element should contribute to understanding
2. **Structure first, aesthetics second** — correct relationships matter more than visual polish
3. **Label everything meaningful** — connections need labels, components need names
4. **Consistency over creativity** — use the defined color system, don't invent new colors
5. **No JavaScript** — the output must work without any scripting (HTML/SVG formats)
6. **Escape all user text** — HTML-entity-escape `<`, `>`, `&`, `"`, `'` in all labels, titles, and descriptions before inserting into SVG/HTML to prevent XSS

## Style Decision Guide

| Situation | Recommended style |
|-----------|------------------|
| Technical article, documentation | `dark-professional` |
| Presentation, slide deck | `dark-professional` |
| Whiteboard/teaching context | `hand-drawn` |
| Blog post with casual tone | `hand-drawn` |
| Enterprise architecture review | `light-corporate` |
| Stakeholder/business presentation | `light-corporate` |
| Developer tool, CLI product | `cyberpunk-neon` |
| Futuristic/tech-forward content | `cyberpunk-neon` |
| Engineering spec, technical drawing | `blueprint` |
| Infrastructure/SRE documentation | `blueprint` |
| Educational content, tutorial | `warm-cozy` |
| Non-technical audience, friendly docs | `warm-cozy` |

## Iteration Workflow

After generating the initial diagram, the user may request changes:
- Add/remove components → update JSON, recompute layout
- Change a connection → update JSON connections, recompute paths
- Change style → switch template, keep same JSON
- Change diagram type → re-extract JSON for new type, regenerate
- Change output format → regenerate from existing JSON

## Quality Checklist

Before delivering, verify:
- [ ] JSON validates against the diagram type's schema
- [ ] Every `<text>` has `text-anchor` and `dominant-baseline` attributes (see `references/design-system.md`)
- [ ] Text is visually centered inside its parent box (text_x = box_x + box_w/2, text_y = box_y + box_h/2)
- [ ] Connection lines end exactly at component edges, not floating or crossing borders
- [ ] All components of the same type/level share identical y-coordinates (horizontal alignment)
- [ ] Spacing between same-level components is consistent (same gap everywhere)
- [ ] ViewBox fits all content with no clipping and no more than 40px whitespace margin
- [ ] Legend matches the component types used
- [ ] Title and subtitle are accurate
- [ ] Icons (if used) are correctly colored and positioned
