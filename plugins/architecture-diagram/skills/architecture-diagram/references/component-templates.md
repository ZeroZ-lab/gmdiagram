# SVG Component Templates

Copy and adapt these SVG snippets when generating diagram HTML. All coordinates are examples — replace with computed values from layout rules.

**CRITICAL**: Every `<text>` element MUST include `text-anchor="middle" dominant-baseline="central"` (except left-aligned labels like layer names, which use `text-anchor="start"`). See `references/design-system.md` → "Text Alignment (MANDATORY)" for details.

**PREFERRED**: Use the `<g transform="translate(x,y)">` group pattern to position elements. This reduces coordinate calculation errors and makes centering trivial.

## 1. Layer Card (Container for a horizontal band)

```svg
<!-- Layer: Browser Process (process type) -->
<!-- Masking rect (draw FIRST, before arrows) -->
<rect x="40" y="40" width="920" height="100" rx="8" fill="#0f172a"/>
<!-- Styled layer card -->
<rect x="40" y="40" width="920" height="100" rx="8"
      fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1"/>
<!-- Layer label (left-aligned, offset 20px from left edge) -->
<text x="60" y="62" font-size="14" font-weight="600" fill="white"
      font-family="JetBrains Mono, monospace"
      text-anchor="start" dominant-baseline="central">Browser Process</text>
```

## 2. Module Box (Inside a layer) — Group Pattern

```svg
<!-- Module: V8 Engine (module type) at position (80, 75), size 140x50 -->
<g transform="translate(80, 75)">
  <!-- Masking rect -->
  <rect width="140" height="50" rx="6" fill="#0f172a"/>
  <!-- Styled module box -->
  <rect width="140" height="50" rx="6"
        fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
  <!-- Module label — centered at (width/2, height/2) = (70, 25) -->
  <text x="70" y="25" font-size="12" font-weight="500" fill="white"
        font-family="JetBrains Mono, monospace"
        text-anchor="middle" dominant-baseline="central">V8 Engine</text>
</g>
```

## 3. Module with Annotation + Tech Badges — Group Pattern

```svg
<!-- Module: API Server with tech badges at position (80, 75), size 160x58 -->
<g transform="translate(80, 75)">
  <rect width="160" height="58" rx="6" fill="#0f172a"/>
  <rect width="160" height="58" rx="6"
        fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
  <!-- Main label — centered at (80, 20) -->
  <text x="80" y="20" font-size="12" font-weight="500" fill="white"
        font-family="JetBrains Mono, monospace"
        text-anchor="middle" dominant-baseline="central">API Server</text>
  <!-- Tech badges — centered row at y=42 -->
  <rect x="24" y="34" width="52" height="16" rx="4"
        fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
  <text x="50" y="42" font-size="8" fill="#94a3b8"
        font-family="JetBrains Mono, monospace"
        text-anchor="middle" dominant-baseline="central">Node.js</text>
  <rect x="84" y="34" width="52" height="16" rx="4"
        fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
  <text x="110" y="42" font-size="8" fill="#94a3b8"
        font-family="JetBrains Mono, monospace"
        text-anchor="middle" dominant-baseline="central">Express</text>
</g>
```

## 4. Data Store (Cylinder-like) — Group Pattern

```svg
<!-- Data store: PostgreSQL (data type) at position (80, 75), size 140x50 -->
<g transform="translate(80, 75)">
  <rect width="140" height="50" rx="6" fill="#0f172a"/>
  <rect width="140" height="50" rx="6"
        fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1.5"/>
  <!-- Cylinder top ellipse hint -->
  <ellipse cx="70" cy="5" rx="50" ry="5" fill="none"
           stroke="#a78bfa" stroke-width="0.8" stroke-dasharray="3,2"/>
  <!-- Label — centered -->
  <text x="70" y="30" font-size="12" font-weight="500" fill="white"
        font-family="JetBrains Mono, monospace"
        text-anchor="middle" dominant-baseline="central">PostgreSQL</text>
</g>
```

## 5. Connection: Unidirectional Arrow

```svg
<!-- Arrow from component A center-bottom to component B center-top -->
<!-- Connection endpoint rules:
     - Vertical down: x = target_center_x, y1 = source_bottom, y2 = target_top
     - Diagonal: compute midpoint, then offset -->
<line x1="300" y1="90" x2="400" y2="200"
      stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
<!-- Connection label — centered at midpoint -->
<g transform="translate(350, 140)">
  <rect x="-22" y="-10" width="44" height="18" rx="3" fill="#020617" opacity="0.9"/>
  <text x="0" y="0" font-size="10" fill="#94a3b8"
        font-family="JetBrains Mono, monospace"
        text-anchor="middle" dominant-baseline="central">IPC</text>
</g>
```

## 6. Connection: Bidirectional Arrow

```svg
<line x1="300" y1="90" x2="400" y2="200"
      stroke="#64748b" stroke-width="1.5"
      marker-start="url(#arrowhead-rev)" marker-end="url(#arrowhead)"/>
```

## 7. Connection: Dashed Line

```svg
<line x1="300" y1="90" x2="400" y2="200"
      stroke="#64748b" stroke-width="1.5" stroke-dasharray="6,4"
      marker-end="url(#arrowhead)"/>
```

## 8. Security Group Boundary

```svg
<rect x="60" y="170" width="400" height="120" rx="8"
      fill="none" stroke="#fb7185" stroke-width="1.5" stroke-dasharray="6,4"/>
<text x="75" y="188" font-size="11" fill="#fb7185"
      font-family="JetBrains Mono, monospace"
      text-anchor="start" dominant-baseline="central">Security Group</text>
```

## 9. Region Boundary

```svg
<rect x="30" y="30" width="940" height="400" rx="12"
      fill="none" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="8,4"/>
<text x="48" y="50" font-size="11" fill="#fbbf24"
      font-family="JetBrains Mono, monospace"
      text-anchor="start" dominant-baseline="central">AWS Region: us-east-1</text>
```

## 10. Legend — Group Pattern

```svg
<!-- Legend, positioned below all diagram content -->
<g transform="translate(40, 600)">
  <text x="0" y="0" font-size="11" font-weight="600" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace"
        text-anchor="start" dominant-baseline="central">Legend</text>

  <!-- Legend items row at y=22, spaced 100px apart -->
  <g transform="translate(0, 16)">
    <rect width="14" height="14" rx="3" fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee"/>
    <text x="20" y="7" font-size="11" fill="#cbd5e1"
          font-family="JetBrains Mono, monospace"
          text-anchor="start" dominant-baseline="central">Process</text>
  </g>
  <g transform="translate(100, 16)">
    <rect width="14" height="14" rx="3" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399"/>
    <text x="20" y="7" font-size="11" fill="#cbd5e1"
          font-family="JetBrains Mono, monospace"
          text-anchor="start" dominant-baseline="central">Module</text>
  </g>
  <!-- More items with 100px spacing -->
</g>
```

## 11. SVG Defs (Required at start of every SVG)

```svg
<defs>
  <!-- Grid pattern -->
  <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(51, 65, 85, 0.3)" stroke-width="0.5"/>
  </pattern>
  <!-- Forward arrowhead -->
  <marker id="arrowhead" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
    <polygon points="0 0, 8 3, 0 6" fill="#64748b"/>
  </marker>
  <!-- Reverse arrowhead (for bidirectional) -->
  <marker id="arrowhead-rev" markerWidth="8" markerHeight="6" refX="0" refY="3" orient="auto">
    <polygon points="8 0, 0 3, 8 6" fill="#64748b"/>
  </marker>
</defs>
```

## Component Type → Color Mapping (Quick Reference)

When generating component SVG, look up the type to get fill/stroke:

| Type | fill | stroke |
|------|------|--------|
| `process` | `rgba(8, 51, 68, 0.4)` | `#22d3ee` |
| `module` | `rgba(6, 78, 59, 0.4)` | `#34d399` |
| `data` | `rgba(76, 29, 149, 0.4)` | `#a78bfa` |
| `infra` | `rgba(120, 53, 15, 0.3)` | `#fbbf24` |
| `security` | `rgba(136, 19, 55, 0.4)` | `#fb7185` |
| `channel` | `rgba(251, 146, 60, 0.3)` | `#fb923c` |
| `external` | `rgba(30, 41, 59, 0.5)` | `#94a3b8` |
