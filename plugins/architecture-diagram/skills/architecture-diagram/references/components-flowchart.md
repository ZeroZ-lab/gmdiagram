# Flowchart SVG Component Templates

Copy and adapt these SVG snippets when generating flowchart diagram HTML. All coordinates are examples — replace with computed values from `layout-flowchart.md`.

## Node Type Color Mapping (Quick Reference)

| Type | fill | stroke | stroke-width |
|------|------|--------|-------------|
| `start` | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald) | 1.5 |
| `end` | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald) | 1.5 |
| `process` | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald) | 1.5 |
| `decision` | `rgba(120, 53, 15, 0.3)` | `#fbbf24` (amber) | 1.5 |
| `io` | `rgba(8, 51, 68, 0.4)` | `#22d3ee` (cyan) | 1.5 |
| `subprocess` | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald) | 1.5 |
| `document` | `rgba(76, 29, 149, 0.4)` | `#a78bfa` (violet) | 1.5 |

---

## 1. Start / End Terminal (Stadium Shape)

```svg
<!-- Start node: "Start" -->
<!-- Masking rect (draw FIRST, before arrows) -->
<rect x="450" y="40" width="100" height="40" rx="20" fill="#0f172a"/>
<!-- Styled terminal -->
<rect x="450" y="40" width="100" height="40" rx="20"
      fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<!-- Label -->
<text x="500" y="64" font-size="12" font-weight="600" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Start</text>
```

End nodes use the same shape with potentially different label:
```svg
<!-- End node: "End" -->
<rect x="450" y="1040" width="100" height="40" rx="20" fill="#0f172a"/>
<rect x="450" y="1040" width="100" height="40" rx="20"
      fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<text x="500" y="1064" font-size="12" font-weight="600" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">End</text>
```

## 2. Process Node (Rectangle)

```svg
<!-- Process node: "Build Application" -->
<!-- Masking rect -->
<rect x="430" y="240" width="140" height="40" rx="4" fill="#0f172a"/>
<!-- Styled process box -->
<rect x="430" y="240" width="140" height="40" rx="4"
      fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<!-- Label -->
<text x="500" y="264" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Build Application</text>
<!-- Optional description -->
<text x="500" y="278" font-size="9" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Compile & package</text>
```

## 3. Decision Node (Diamond)

```svg
<!-- Decision node: "Tests Pass?" -->
<!-- Diamond polygon centered at (cx=500, cy=485) with w=140, h=90 -->
<!-- Masking polygon (same shape, opaque fill) -->
<polygon points="500,440 570,485 500,530 430,485" fill="#0f172a"/>
<!-- Styled diamond -->
<polygon points="500,440 570,485 500,530 430,485"
         fill="rgba(120, 53, 15, 0.3)" stroke="#fbbf24" stroke-width="1.5"/>
<!-- Label -->
<text x="500" y="482" font-size="11" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Tests</text>
<text x="500" y="496" font-size="11" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Pass?</text>
```

Diamond anchor points for connections:
```
top_vertex    = (cx, cy - h/2)       // (500, 440)
right_vertex  = (cx + w/2, cy)       // (570, 485)
bottom_vertex = (cx, cy + h/2)       // (500, 530)
left_vertex   = (cx - w/2, cy)       // (430, 485)
```

## 4. I/O Parallelogram

```svg
<!-- I/O node: "User Login" (parallelogram) -->
<!-- Skew offset: 12px -->
<!-- Masking polygon -->
<polygon points="442,340 582,340 570,380 430,380" fill="#0f172a"/>
<!-- Styled parallelogram -->
<polygon points="442,340 582,340 570,380 430,380"
         fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1.5"/>
<!-- Label -->
<text x="506" y="364" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">User Login</text>
```

Parallelogram coordinate formula:
```
// Given x, y, w, h, skew=12
top_left     = (x + skew, y)
top_right    = (x + w + skew, y)
bottom_right = (x + w - skew, y + h)
bottom_left  = (x - skew, y + h)
```

## 5. Subprocess Node (Double-Border Rectangle)

```svg
<!-- Subprocess node: "Build" (double-border) -->
<!-- Masking rect -->
<rect x="430" y="240" width="140" height="40" rx="4" fill="#0f172a"/>
<!-- Outer rect -->
<rect x="430" y="240" width="140" height="40" rx="4"
      fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<!-- Inner rect (inset 3px on left and right sides only) -->
<rect x="436" y="240" width="128" height="40" rx="2"
      fill="none" stroke="#34d399" stroke-width="0.8"/>
<!-- Label -->
<text x="500" y="264" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Build</text>
```

Inner rect formula:
```
inner_x = x + SUBPROCESS_INSET * 2  // 3px inset on left
inner_w = w - SUBPROCESS_INSET * 4  // 3px inset on each side (left + right)
inner_rx = max(2, rx - 2)
```

## 6. Document Node (Wavy Bottom)

```svg
<!-- Document node: "Log Audit Entry" (wavy bottom) -->
<!-- Masking path -->
<path d="M 430,600 L 570,600 L 570,635 Q 540,645 500,635 Q 460,625 430,635 Z"
      fill="#0f172a"/>
<!-- Styled document shape -->
<path d="M 430,600 L 570,600 L 570,635 Q 540,645 500,635 Q 460,625 430,635 Z"
      fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1.5"/>
<!-- Label -->
<text x="500" y="622" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Log Audit Entry</text>
```

Wavy bottom path formula:
```
// Given x, y, w, h, wave_amplitude=5
path = "M {x},{y}                          // top-left
        L {x+w},{y}                         // top-right
        L {x+w},{y+h}                       // right side down
        Q {x+w*0.75},{y+h+wave_amp}         // wave curve 1
          {x+w*0.5},{y+h}                   // wave midpoint
        Q {x+w*0.25},{y+h-wave_amp}         // wave curve 2
          {x},{y+h}                          // wave end
        Z"                                   // close to top-left
```

## 7. Connection Arrow: Solid (Down)

```svg
<!-- Solid arrow from source bottom-center to target top-center -->
<line x1="500" y1="80" x2="500" y2="140"
      stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
```

## 8. Connection Arrow: Dashed

```svg
<!-- Dashed arrow (for fail/optional paths) -->
<line x1="500" y1="80" x2="500" y2="140"
      stroke="#64748b" stroke-width="1.5" stroke-dasharray="6,4"
      marker-end="url(#arrowhead)"/>
```

## 9. Connection Arrow: With Label

```svg
<!-- Arrow with label background and text -->
<line x1="500" y1="280" x2="500" y2="340"
      stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
<!-- Label background -->
<rect x="484" y="296" width="32" height="16" rx="3" fill="#0f172a" opacity="0.9"/>
<!-- Label text -->
<text x="500" y="308" font-size="10" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Yes</text>
```

## 10. Loop-Back Arrow (Cubic Bezier)

```svg
<!-- Loop-back from decision "No" branch back to earlier node -->
<!-- Routes along the right side of the diagram -->
<path d="M 570,485 C 650,485 640,160 560,160"
      fill="none" stroke="#fb923c" stroke-width="1.5" stroke-dasharray="6,4"
      marker-end="url(#arrowhead-loop)"/>
<!-- Branch label -->
<rect x="622" y="300" width="40" height="16" rx="3" fill="#0f172a" opacity="0.9"/>
<text x="642" y="312" font-size="10" fill="#fb923c"
      font-family="JetBrains Mono, monospace" text-anchor="middle">No</text>
```

Loop-back arrows use orange (`#fb923c`) stroke to visually distinguish them from the main flow.

## 11. Decision Branch Labels ("Yes" / "No")

```svg
<!-- "Yes" label below decision diamond (on the down path) -->
<text x="500" y="545" font-size="10" font-weight="600" fill="#34d399"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Yes</text>

<!-- "No" label to the right of decision diamond (on the right path) -->
<text x="582" y="482" font-size="10" font-weight="600" fill="#fb7185"
      font-family="JetBrains Mono, monospace" text-anchor="start">No</text>
```

Color coding for branch labels:
- **Yes** (positive path): `#34d399` (emerald/green)
- **No** (negative path): `#fb7185` (rose/red)
- **Default** (fallback): `#94a3b8` (slate/gray)

## 12. Swimlane Band

```svg
<!-- Swimlane: "Developer" -->
<rect x="40" y="20" width="920" height="160" rx="0"
      fill="none" stroke="rgba(148, 163, 184, 0.2)" stroke-width="1"/>
<!-- Swimlane label (rotated vertical text on left) -->
<text x="55" y="100" font-size="11" font-weight="600" fill="#cbd5e1"
      font-family="JetBrains Mono, monospace" text-anchor="middle"
      writing-mode="tb">Developer</text>
<!-- Separator line (right edge of label column) -->
<line x1="120" y1="20" x2="120" y2="180"
      stroke="rgba(148, 163, 184, 0.15)" stroke-width="1"/>
```

Swimlane band height includes top/bottom padding of 20px each:
```
band_h = max(node_h for nodes in lane) + 40
```

## 13. Swimlane Separator (Between Bands)

```svg
<!-- Separator between swimlanes -->
<line x1="40" y1="180" x2="960" y2="180"
      stroke="rgba(148, 163, 184, 0.15)" stroke-width="1"/>
```

## 14. Legend (Flowchart)

```svg
<!-- Legend, positioned below all diagram content -->
<g transform="translate(40, 1100)">
  <text x="0" y="0" font-size="11" font-weight="600" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Legend</text>

  <!-- Legend item: Start/End -->
  <rect x="0" y="12" width="30" height="14" rx="7"
        fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1"/>
  <text x="36" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Start / End</text>

  <!-- Legend item: Process -->
  <rect x="130" y="12" width="14" height="14" rx="2"
        fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1"/>
  <text x="150" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Process</text>

  <!-- Legend item: Decision -->
  <polygon points="255,12 262,19 255,26 248,19"
           fill="rgba(120, 53, 15, 0.3)" stroke="#fbbf24" stroke-width="1"/>
  <text x="270" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Decision</text>

  <!-- Legend item: I/O -->
  <polygon points="360,12 380,12 377,26 357,26"
           fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1"/>
  <text x="386" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">I/O</text>

  <!-- Legend item: Loop-back -->
  <path d="M 440,19 C 450,19 455,12 455,12"
        fill="none" stroke="#fb923c" stroke-width="1.5" stroke-dasharray="4,2"/>
  <text x="462" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Loop-back</text>
</g>
```

## 15. SVG Defs (Required at start of every flowchart SVG)

```svg
<defs>
  <!-- Grid pattern -->
  <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(51, 65, 85, 0.3)" stroke-width="0.5"/>
  </pattern>
  <!-- Forward arrowhead (main flow) -->
  <marker id="arrowhead" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
    <polygon points="0 0, 8 3, 0 6" fill="#64748b"/>
  </marker>
  <!-- Loop-back arrowhead (orange) -->
  <marker id="arrowhead-loop" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
    <polygon points="0 0, 8 3, 0 6" fill="#fb923c"/>
  </marker>
  <!-- Reverse arrowhead (for bidirectional) -->
  <marker id="arrowhead-rev" markerWidth="8" markerHeight="6" refX="0" refY="3" orient="auto">
    <polygon points="8 0, 0 3, 8 6" fill="#64748b"/>
  </marker>
</defs>
```

## Rendering Order

When composing the final SVG, draw elements in this order:

1. Grid background (`<rect fill="url(#grid)" />`)
2. Swimlane bands and separators
3. All connection lines and arrows (behind nodes)
4. All node shapes (on top of arrows) — masking rects first, then styled shapes
5. All labels (text on top of everything)
6. Legend

This order ensures arrows go behind nodes and text is always readable.
