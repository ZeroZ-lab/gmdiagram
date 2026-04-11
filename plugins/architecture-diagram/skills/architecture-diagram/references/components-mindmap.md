# Mind Map SVG Component Templates

Copy and adapt these SVG snippets when generating mind map HTML. All coordinates are examples — replace with computed values from `layout-mindmap.md`.

## Color Coding System

Each top-level branch gets a distinct hue from the design system palette. Children inherit a lighter shade of their parent's color.

### Level Color Rules

| Level | Color Source | Example |
|-------|-------------|---------|
| 0 (central node) | Style accent color | `#22d3ee` (dark-professional cyan) |
| 1 (top-level branch) | Unique color from palette per branch | Branch A: `#34d399`, Branch B: `#a78bfa` |
| 2+ (sub-branches) | Lighter shade of parent's color | `#34d399` -> `#6ee7b7` -> `#a7f3d0` |

### Branch Color Palette (Top-Level Assignment)

Assign colors in order to top-level branches:

| Branch Index | Color Name | Hex | Light Shade (Level 2) | Lightest (Level 3) |
|-------------|-----------|-----|----------------------|-------------------|
| 0 | Emerald | `#34d399` | `#6ee7b7` | `#a7f3d0` |
| 1 | Violet | `#a78bfa` | `#c4b5fd` | `#ddd6fe` |
| 2 | Amber | `#fbbf24` | `#fcd34d` | `#fde68a` |
| 3 | Rose | `#fb7185` | `#fda4af` | `#fecdd3` |
| 4 | Sky | `#38bdf8` | `#7dd3fc` | `#bae6fd` |
| 5 | Orange | `#fb923c` | `#fdba74` | `#fed7aa` |
| 6 | Teal | `#2dd4bf` | `#5eead4` | `#99f6e4` |
| 7 | Pink | `#f472b6` | `#f9a8d4` | `#fbcfe8` |

For styles other than dark-professional, adapt colors from the style's design system.

## 1. Central Node

The central node is a prominent circle or rounded rectangle placed at the center of the SVG.

### Circle variant

```svg
<!-- Central node: "gmdiagram" -->
<circle cx="600" cy="400" r="50"
        fill="rgba(8, 51, 68, 0.6)" stroke="#22d3ee" stroke-width="2.5"/>
<text x="600" y="396" font-size="13" font-weight="700" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">gmdiagram</text>
<!-- Optional second line -->
<text x="600" y="412" font-size="9" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Skill Engine</text>
```

### Rounded rect variant (for longer labels)

```svg
<!-- Central node as rounded rect -->
<rect x="530" y="370" width="140" height="60" rx="16"
      fill="rgba(8, 51, 68, 0.6)" stroke="#22d3ee" stroke-width="2.5"/>
<text x="600" y="396" font-size="13" font-weight="700" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">gmdiagram</text>
<text x="600" y="412" font-size="9" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Skill Engine</text>
```

## 2. Branch Node (Level 1 — Top-Level Branch)

Prominent rounded rectangle with distinct color.

```svg
<!-- Branch node: "Diagram Types" (Level 1, right side, emerald) -->
<!-- Masking rect -->
<rect x="770" y="214" width="120" height="32" rx="12" fill="#0f172a"/>
<!-- Styled branch -->
<rect x="770" y="214" width="120" height="32" rx="12"
      fill="rgba(6, 78, 59, 0.5)" stroke="#34d399" stroke-width="1.8"/>
<!-- Label -->
<text x="830" y="234" font-size="11" font-weight="600" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Diagram Types</text>
```

## 3. Branch Node (Level 2 — Sub-Branch)

Smaller, lighter shade of parent's color.

```svg
<!-- Sub-branch: "Architecture" (Level 2, right side, light emerald) -->
<rect x="910" y="90" width="100" height="32" rx="10"
      fill="rgba(6, 78, 59, 0.3)" stroke="#6ee7b7" stroke-width="1.2"/>
<text x="960" y="110" font-size="10" font-weight="500" fill="#cbd5e1"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Architecture</text>
```

## 4. Branch Node (Level 3 — Leaf)

Subtle, lightest shade. Often leaf nodes with no children.

```svg
<!-- Leaf node: "REST API" (Level 3, right side, lightest emerald) -->
<rect x="1050" y="150" width="80" height="28" rx="8"
      fill="rgba(6, 78, 59, 0.15)" stroke="#a7f3d0" stroke-width="0.8"/>
<text x="1090" y="168" font-size="9" font-weight="400" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">REST API</text>
```

## 5. Branch Connection: Right Side (Cubic Bezier)

Connects parent's right edge to child's left edge, curving smoothly rightward.

```svg
<!-- Connection: central node → Diagram Types (right side) -->
<path d="M 650,416 C 690,416 730,230 770,230"
      fill="none" stroke="#34d399" stroke-width="1.5" opacity="0.7"/>

<!-- Connection: Diagram Types → Architecture (right side, level 2) -->
<path d="M 890,230 C 930,230 950,106 910,106"
      fill="none" stroke="#6ee7b7" stroke-width="1.2" opacity="0.6"/>
```

**Right-side path formula**:
```
M x1,y1 C (x1+40),y1 (x2-40),y2 x2,y2
```
Where:
- `(x1, y1)` = parent right edge center
- `(x2, y2)` = child left edge center

## 6. Branch Connection: Left Side (Cubic Bezier)

Connects parent's left edge to child's right edge, curving smoothly leftward.

```svg
<!-- Connection: central node → Output Formats (left side) -->
<path d="M 550,416 C 510,416 430,323 430,323"
      fill="none" stroke="#fbbf24" stroke-width="1.5" opacity="0.7"/>

<!-- Connection: Output Formats → HTML (left side, level 2) -->
<path d="M 330,307 C 290,307 250,270 250,270"
      fill="none" stroke="#fcd34d" stroke-width="1.2" opacity="0.6"/>
```

**Left-side path formula**:
```
M x1,y1 C (x1-40),y1 (x2+40),y2 x2,y2
```
Where:
- `(x1, y1)` = parent left edge center
- `(x2, y2)` = child right edge center

## 7. Branch Connection: From Central Node

Special case — connections originate from the circle edge rather than a rectangle edge.

```svg
<!-- Right-side from central circle -->
<!-- x1 = center_x + CENTER_NODE_R, y1 = center_y -->
<path d="M 650,416 C 690,416 730,230 770,230"
      fill="none" stroke="#34d399" stroke-width="1.5" opacity="0.7"/>

<!-- Left-side from central circle -->
<!-- x1 = center_x - CENTER_NODE_R, y1 = center_y -->
<path d="M 550,416 C 510,416 430,323 430,323"
      fill="none" stroke="#fbbf24" stroke-width="1.5" opacity="0.7"/>
```

## 8. Legend

```svg
<!-- Legend, positioned below all mind map content -->
<g transform="translate(40, 860)">
  <text x="0" y="0" font-size="11" font-weight="600" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Legend</text>

  <!-- Legend item: Diagram Types -->
  <rect x="0" y="12" width="14" height="14" rx="3"
        fill="rgba(6, 78, 59, 0.5)" stroke="#34d399" stroke-width="1"/>
  <text x="20" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Diagram Types</text>

  <!-- Legend item: Visual Styles -->
  <rect x="140" y="12" width="14" height="14" rx="3"
        fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1"/>
  <text x="160" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Visual Styles</text>

  <!-- Legend items continue horizontally with ~140px spacing -->
</g>
```

## 9. SVG Defs (Required at Start of Every Mind Map SVG)

```svg
<defs>
  <!-- Grid pattern (optional, for background) -->
  <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(51, 65, 85, 0.3)" stroke-width="0.5"/>
  </pattern>
  <!-- Glow filter for central node -->
  <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
    <feGaussianBlur stdDeviation="4" result="blur"/>
    <feMerge>
      <feMergeNode in="blur"/>
      <feMergeNode in="SourceGraphic"/>
    </feMerge>
  </filter>
</defs>
```

## Style-Specific Adaptations

### dark-professional
- Central node: `fill="rgba(8, 51, 68, 0.6)"`, `stroke="#22d3ee"`, `stroke-width="2.5"`
- Connections: colored stroke with `opacity="0.7"`
- Background: `#0f172a` with grid pattern

### hand-drawn
- Add `stroke-dasharray="3,2"` to branch rects for sketch feel
- Use `stroke-width="2"` for rough appearance
- Connections: `stroke-dasharray="6,3"`

### light-corporate
- Central node: `fill="#1e40af"`, `stroke="#3b82f6"`, white text
- Branches: white fill with colored left border
- Connections: thin gray or colored lines

### cyberpunk-neon
- Central node: neon glow filter, bright stroke
- Connections: glowing neon lines with double stroke
- Branches: dark fill with neon border

### blueprint
- Central node: white fill, blue stroke, `stroke-width="2"`
- Branches: light blue fill, darker blue stroke
- Connections: dashed blue lines

### warm-cozy
- Central node: warm orange/brown fill, cream text
- Branches: soft pastel fills with warm borders
- Connections: soft brown/orange curves
