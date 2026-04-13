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
  Supports 5 diagram types and 9 visual styles: dark-professional, hand-drawn, light-corporate, cyberpunk-neon, blueprint, warm-cozy, minimalist, terminal-retro, pastel-dream.
  Supports 4 output formats: html, svg, mermaid, png/pdf (via export script).
---

# gmdiagram — Architecture Diagram Skill

## What This Skill Does

Generate publication-quality diagrams as standalone files. The output can be:
- **HTML**: Single `.html` file with inline SVG and embedded CSS (default, no JavaScript)
- **SVG**: Standalone `.svg` file
- **Mermaid**: Mermaid text syntax (paste into GitHub, Notion, etc.)
- **PNG/PDF**: Via the export script at `scripts/export.sh`

## Interactive Selection

When the user's request does NOT already specify all three choices (diagram type, style, output format), use the `AskUserQuestion` tool to let the user choose.

**Important**: `AskUserQuestion` supports at most **4 options per question** and **4 questions per call**. When there are more than 4 choices, split into two calls or use the auto-infer + confirm pattern below.

### Selection Strategy

For each dimension, follow this logic:

1. **Can the choice be inferred from the user's description?** → Skip asking, use the inferred value directly.
2. **Does the user explicitly state it?** → Skip asking, use the stated value.
3. **Still ambiguous?** → Ask via `AskUserQuestion`.

### Question 1 — Diagram Type (ask only if ambiguous)

The user's description usually makes the type obvious. Only ask when multiple types could fit.

```
question: "Which diagram type fits your needs?"
header: "Type"
multiSelect: false
options:
  - label: "Architecture"
    description: "System layers, services, infrastructure, platform maps"
  - label: "Flowchart"
    description: "Process flow, decision tree, branching logic"
  - label: "Mind Map"
    description: "Topic hierarchy, brainstorm, feature tree"
  - label: "Other"
    description: "ER Diagram (data model) or Sequence Diagram (message flow)"
```

If the user picks "Other", ask a follow-up:
```
question: "Which specific type?"
header: "Type"
multiSelect: false
options:
  - label: "ER Diagram"
    description: "Database tables, entities, relationships, data model"
  - label: "Sequence Diagram"
    description: "Message flow, API calls, protocol, interaction between actors"
```

### Question 2 — Visual Style (always ask unless user named a style)

Split into three style families. First call asks for family:

**First call:**
```
question: "Which style family?"
header: "Style"
multiSelect: false
options:
  - label: "Dark"
    description: "Dark Professional, Cyberpunk Neon, or Terminal Retro"
  - label: "Light / Clean"
    description: "Light Corporate, Minimalist, or Warm Cozy"
  - label: "Creative"
    description: "Hand-Drawn, Blueprint, or Pastel Dream"
```

Then follow up based on the family:

**Dark follow-up:**
```
options:
  - label: "Dark Professional (Recommended)"
    description: "Neon accents, tech articles, docs, presentations"
  - label: "Cyberpunk Neon"
    description: "Catppuccin dark, vivid neon, developer tools"
  - label: "Terminal Retro"
    description: "CRT green-on-black, scanlines, developer blogs"
```

**Light follow-up:**
```
options:
  - label: "Light Corporate"
    description: "Clean white, muted palette, enterprise reviews"
  - label: "Minimalist"
    description: "Monochrome, ultra-thin borders, maximum whitespace"
  - label: "Warm Cozy"
    description: "Warm cream, soft tones, tutorials"
```

**Creative follow-up:**
```
options:
  - label: "Hand-Drawn Sketch"
    description: "Warm beige, sketchy borders, whiteboard feel"
  - label: "Blueprint"
    description: "Nord blue, grid lines, engineering specs"
  - label: "Pastel Dream"
    description: "Soft pastels, rounded corners, playful"
```

### Question 3 — Output Format (always ask unless user named a format)

```
question: "Which output format?"
header: "Format"
multiSelect: false
options:
  - label: "HTML (Recommended)"
    description: "Single file with inline SVG, opens in any browser"
  - label: "SVG"
    description: "Standalone SVG for vector editors (Figma, Illustrator)"
  - label: "Mermaid"
    description: "Text syntax, paste into GitHub, Notion, or markdown"
  - label: "PNG / PDF"
    description: "Image export via script (requires Node.js or rsvg-convert)"
```

### How to Combine Questions

Minimize the number of `AskUserQuestion` calls:

- **User specified nothing**: First call asks Type + Style family + Format (3 questions). Then a follow-up call if they picked "Other" type or "Creative" style.
- **User specified type only**: Ask Style family + Format (2 questions). Follow-up if "Creative" style.
- **User specified type + style**: Ask Format only (1 question, 1 call).
- **User specified everything**: Skip all selection, proceed directly to generation.

### Rules

1. If the user already specified all three, skip selection entirely.
2. Only ask about dimensions the user hasn't specified.
3. Put `(Recommended)` on the default/first option for style and format.
4. After all selections are made, proceed to the Two-Step Generation Process below.

### Density (default: normal, never ask)

Density defaults to `"normal"`. Infer from the user's description — never ask via AskUserQuestion:
- "compact" / "dense" / "tight" / "紧凑" → `"compact"`
- "spacious" / "spread out" / "presentation" / "宽松" → `"spacious"`
- Otherwise → `"normal"`

When density differs from normal, read the "Density Multipliers" section in the corresponding layout reference file to get adjusted spacing constants.

### Direction (default: TB, never ask)

Direction defaults to `"TB"` (top-to-bottom). Only applies to `architecture` and `flowchart`. Infer from user description:
- "left to right" / "horizontal" / "LR" / "从左到右" → `"LR"`
- Otherwise → `"TB"`

When direction is `"LR"`, read the "LR Mode" section in the layout reference file for transformed coordinate rules. ER, sequence, and mindmap diagrams always use their inherent layout — ignore direction for these types.

### Font and Color Overrides (ask only if user requests)

After all selections, if the user mentions custom colors, fonts, or brand colors, apply overrides from the `font` and `colors` fields in the JSON schema.

**Font override:** When `font` is set, add a Google Fonts `<link>` in the HTML `<head>` and replace all `font-family` declarations with the user's font as primary.

**Color overrides:** When `colors` object is present:
- `colors.primary` replaces the style's primary accent/border color
- `colors.secondary` replaces subtle border and background colors
- `colors.accent` replaces highlight colors
- `colors.background` replaces the page background color
- `colors.text` replaces primary text color

Apply overrides LAST, after all style template values are resolved. Override colors replace corresponding values in type color mapping, connection lines, and legend swatches.

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
- If the user doesn't specify a density, use `normal`
- If the user doesn't specify a direction, use `TB` (architecture/flowchart only)
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
   - `minimalist` → `references/style-minimalist.md` → `assets/template-minimalist.html`
   - `terminal-retro` → `references/style-terminal-retro.md` → `assets/template-terminal-retro.html`
   - `pastel-dream` → `references/style-pastel-dream.md` → `assets/template-pastel-dream.html`

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

## Diagram Type Reference

When the diagram type is clear from context (or after the user selects it), use this mapping:

| Diagram Type | Reference File | Schema File |
|---|---|---|
| `architecture` | `references/diagram-architecture.md` | `assets/schema-architecture.json` |
| `flowchart` | `references/diagram-flowchart.md` | `assets/schema-flowchart.json` |
| `mindmap` | `references/diagram-mindmap.md` | `assets/schema-mindmap.json` |
| `er` | `references/diagram-er.md` | `assets/schema-er.json` |
| `sequence` | `references/diagram-sequence.md` | `assets/schema-sequence.json` |

Read the diagram-type-registry at `references/diagram-type-registry.md` for detailed trigger keywords.

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
- [ ] Every `<foreignObject>` has `xmlns="http://www.w3.org/1999/xhtml"` on the root HTML element
- [ ] Component boxes use CSS classes from the template (`.module`, `.type-X`, `.module-label`)
- [ ] SVG `<text>` (connection labels only) has `text-anchor="middle" dominant-baseline="central"`
- [ ] Connection lines route around intermediate layers (never cross through layer cards)
- [ ] Masking rects cover full layer area (hides arrows behind components)
- [ ] **Every layer height is exactly LAYER_H_BADGE (116) or LAYER_H_SIMPLE (101) — NEVER custom heights like 49, 80, or 106**
- [ ] **NO overlapping layers: gap between every pair of adjacent layers = exactly 50px**
- [ ] Layer y-positions are correctly stacked: `layer_y[i] = layer_y[i-1] + h + gap`
- [ ] ViewBox fits all content with no clipping and no more than 40px whitespace margin
- [ ] Legend matches the component types used
- [ ] Title and subtitle are accurate
- [ ] Icons (if used) are correctly colored and positioned
