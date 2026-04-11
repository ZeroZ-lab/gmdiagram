# Design System Reference

## Color Palette (Dark Professional Theme)

### Background
- Page background: `#020617` (slate-950)
- Grid lines: `rgba(51, 65, 85, 0.3)` (slate-700, 30% opacity)
- Grid spacing: 40px
- Card background: `#0f172a` (slate-900)

### Component Colors (Fill + Stroke)

| Type | Fill (rgba) | Stroke | Use for |
|------|-------------|--------|---------|
| `process` | `rgba(8, 51, 68, 0.4)` | `#22d3ee` (cyan-400) | Processes, services |
| `module` | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald-400) | Sub-modules, libraries |
| `data` | `rgba(76, 29, 149, 0.4)` | `#a78bfa` (violet-400) | Databases, storage |
| `infra` | `rgba(120, 53, 15, 0.3)` | `#fbbf24` (amber-400) | Infrastructure, cloud |
| `security` | `rgba(136, 19, 55, 0.4)` | `#fb7185` (rose-400) | Auth, encryption |
| `channel` | `rgba(251, 146, 60, 0.3)` | `#fb923c` (orange-400) | Message buses, IPC |
| `external` | `rgba(30, 41, 59, 0.5)` | `#94a3b8` (slate-400) | External systems |

### Masking
All semi-transparent component boxes MUST have an opaque background rect underneath:
1. First draw: `<rect fill="#0f172a" .../>` (masks arrows behind the box)
2. Then draw: `<rect fill="rgba(...)" stroke="..." .../>` (the visible styled box)

## Typography

- Font: `JetBrains Mono, 'SF Mono', 'Fira Code', monospace`
- Layer label: 14px, font-weight 600, fill white
- Module label: 12px, font-weight 500, fill white
- Sub-label / annotation: 9px, fill #94a3b8 (slate-400)
- Tech badge: 8px, fill #64748b (slate-500)
- Connection label: 10px, fill #94a3b8 (slate-400)
- Legend text: 11px, fill #cbd5e1 (slate-300)

## Text Alignment (MANDATORY)

Every `<text>` element in the SVG MUST include these two attributes for proper alignment:

```svg
text-anchor="middle" dominant-baseline="central"
```

This eliminates the need to manually calculate text offsets. Instead:

- **Horizontal centering**: Set `x` to the center of the parent container. `text-anchor="middle"` handles the rest.
- **Vertical centering**: Set `y` to the center of the parent container. `dominant-baseline="central"` handles the rest.

**Module label center calculation:**
```
text_x = module_x + module_width / 2
text_y = module_y + module_height / 2
```

**Example (correct):**
```svg
<!-- Module box at (80, 75), size 140x50 -->
<rect x="80" y="75" width="140" height="50" rx="6" fill="#0f172a"/>
<rect x="80" y="75" width="140" height="50" rx="6" fill="rgba(6,78,59,0.4)" stroke="#34d399"/>
<text x="150" y="100" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace"
      text-anchor="middle" dominant-baseline="central">V8 Engine</text>
```

**Exception**: Layer labels and legend items that are left-aligned use `text-anchor="start"` instead.

## Group Positioning Pattern

Use `<g transform="translate(x,y)">` to position groups of elements. This reduces coordinate calculation errors:

```svg
<!-- Good: group pattern — compute position ONCE -->
<g transform="translate(80, 75)">
  <rect width="140" height="50" rx="6" fill="#0f172a"/>
  <rect width="140" height="50" rx="6" fill="rgba(6,78,59,0.4)" stroke="#34d399"/>
  <text x="70" y="25" font-size="12" text-anchor="middle" dominant-baseline="central"
        fill="white" font-family="JetBrains Mono, monospace">V8 Engine</text>
</g>
```

All inner coordinates are relative to the group origin (0,0), making centering trivial:
- `text_x = width / 2`
- `text_y = height / 2`

## Spacing

- Layer vertical gap: 50px
- Module horizontal gap: 20px
- Module internal padding: 16px (horizontal), 12px (vertical)
- Module minimum width: 100px
- Module minimum height: 50px
- Layer card padding: 16px
- Legend offset from diagram: 30px below lowest element
- Page margin: 40px

## Borders & Shapes

- Component box: `rx="6"`, stroke-width 1.5px
- Security group: `rx="8"`, stroke-dasharray="6,4", stroke-width 1.5px, stroke rose
- Region boundary: `rx="12"`, stroke-dasharray="8,4", stroke-width 1.5px, stroke amber
- Layer card: `rx="8"`, stroke-width 1px

## Arrows & Connections

- Arrow marker: filled triangle, size 8x6, same color as stroke
- Default stroke: #64748b (slate-500), stroke-width 1.5px
- Bidirectional: arrowheads on both ends
- Dashed: stroke-dasharray="6,4"
- Dotted: stroke-dasharray="2,4"
- Connection labels: positioned at midpoint of the line, with small background rect

## Tech Badges

- Small pill shapes below module name
- Fill: rgba(255,255,255,0.08)
- Stroke: rgba(255,255,255,0.15)
- rx="4", height 16px
- Text: 8px, fill #94a3b8

## Summary Cards (bottom of page)

Three cards in a row, each with:
- Background: #0f172a (slate-900)
- Border: 1px solid rgba(255,255,255,0.08)
- Header dot: 8px circle, colored by primary type
- Title: 13px, white, font-weight 500
- Content: 11px, #94a3b8

## Page Structure

```
┌─────────────────────────────────────┐
│ Header: Title + Subtitle + Dot      │
├─────────────────────────────────────┤
│                                     │
│   SVG Diagram (in rounded card)     │
│   ┌───────────────────────────────┐ │
│   │  Grid background              │ │
│   │  Layer 1: [...]               │ │
│   │  Layer 2: [...]               │ │
│   │  Layer 3: [...]               │ │
│   │  Legend                        │ │
│   └───────────────────────────────┘ │
│                                     │
│ ┌─────┐  ┌─────┐  ┌─────┐         │
│ │Card1│  │Card2│  │Card3│          │
│ └─────┘  └─────┘  └─────┘         │
│                                     │
│ Footer                              │
└─────────────────────────────────────┘
```

## Icon System

Icons can be referenced in the JSON schema via the optional `"icon"` field:
```json
{ "id": "api-server", "label": "API Server", "type": "module", "icon": "tabler-server" }
```

### Sizing Rules
- Icon viewBox: 24×24
- Rendered size: 16×16 (inside modules), 20×20 (inside layer headers)
- Position: 8px left of the label text
- Module width calculation: add 24px (16px icon + 8px gap) when icon is present

### Color Rules
- Icon stroke/fill color inherits the component's stroke color
- In dark themes: use stroke with no fill (outline style)
- In light themes: use fill with no stroke (solid style)
- Icons must adapt to the current style's color system

### Embedding in SVG
```svg
<g transform="translate(x, y)">
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="[path from catalog]"/>
  </svg>
</g>
```

### Icon Catalog
See `references/icons-catalog.md` for the full list of available icons with SVG paths.
