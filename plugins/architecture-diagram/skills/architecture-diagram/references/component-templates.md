# SVG Component Templates

Copy and adapt these SVG snippets when generating diagram HTML. All coordinates are examples — replace with computed values from layout rules.

## 1. Layer Card (Container for a horizontal band)

```svg
<!-- Layer: Browser Process (process type) -->
<!-- Masking rect (draw FIRST, before arrows) -->
<rect x="40" y="40" width="920" height="100" rx="8" fill="#0f172a"/>
<!-- Styled layer card -->
<rect x="40" y="40" width="920" height="100" rx="8"
      fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1"/>
<!-- Layer label -->
<text x="60" y="62" font-size="14" font-weight="600" fill="white"
      font-family="JetBrains Mono, monospace">Browser Process</text>
```

## 2. Module Box (Inside a layer)

```svg
<!-- Module: V8 Engine (module type) -->
<!-- Masking rect -->
<rect x="80" y="75" width="140" height="50" rx="6" fill="#0f172a"/>
<!-- Styled module box -->
<rect x="80" y="75" width="140" height="50" rx="6"
      fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<!-- Module label -->
<text x="150" y="100" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">V8 Engine</text>
<!-- Optional annotation -->
<text x="150" y="115" font-size="9" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">JavaScript Runtime</text>
```

## 3. Module with Tech Badges

```svg
<!-- Module: API Server with tech badges -->
<rect x="80" y="75" width="160" height="58" rx="6" fill="#0f172a"/>
<rect x="80" y="75" width="160" height="58" rx="6"
      fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
<text x="160" y="98" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">API Server</text>
<!-- Tech badge: Node.js -->
<rect x="100" y="108" width="52" height="16" rx="4"
      fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
<text x="126" y="119" font-size="8" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Node.js</text>
<!-- Tech badge: Express -->
<rect x="158" y="108" width="52" height="16" rx="4"
      fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="0.5"/>
<text x="184" y="119" font-size="8" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">Express</text>
```

## 4. Data Store (Cylinder-like)

```svg
<!-- Data store: PostgreSQL (data type) -->
<rect x="80" y="75" width="140" height="50" rx="6" fill="#0f172a"/>
<rect x="80" y="75" width="140" height="50" rx="6"
      fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1.5"/>
<!-- Cylinder top ellipse hint -->
<ellipse cx="150" cy="80" rx="50" ry="5" fill="none"
         stroke="#a78bfa" stroke-width="0.8" stroke-dasharray="3,2"/>
<text x="150" y="105" font-size="12" font-weight="500" fill="white"
      font-family="JetBrains Mono, monospace" text-anchor="middle">PostgreSQL</text>
```

## 5. Connection: Unidirectional Arrow

```svg
<!-- Arrow from component A to component B -->
<!-- The arrowhead marker must be defined in <defs> -->
<line x1="300" y1="90" x2="400" y2="200"
      stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
<!-- Connection label -->
<rect x="320" y="130" width="36" height="16" rx="3" fill="#0f172a" opacity="0.9"/>
<text x="338" y="142" font-size="10" fill="#94a3b8"
      font-family="JetBrains Mono, monospace" text-anchor="middle">IPC</text>
```

## 6. Connection: Bidirectional Arrow

```svg
<!-- Bidirectional arrow -->
<line x1="300" y1="90" x2="400" y2="200"
      stroke="#64748b" stroke-width="1.5"
      marker-start="url(#arrowhead-rev)" marker-end="url(#arrowhead)"/>
```

## 7. Connection: Dashed Line

```svg
<!-- Dashed connection (async/optional) -->
<line x1="300" y1="90" x2="400" y2="200"
      stroke="#64748b" stroke-width="1.5" stroke-dasharray="6,4"
      marker-end="url(#arrowhead)"/>
```

## 8. Security Group Boundary

```svg
<!-- Security group wrapping components -->
<rect x="60" y="170" width="400" height="120" rx="8"
      fill="none" stroke="#fb7185" stroke-width="1.5" stroke-dasharray="6,4"/>
<!-- Group label -->
<text x="75" y="188" font-size="11" fill="#fb7185"
      font-family="JetBrains Mono, monospace">Security Group</text>
```

## 9. Region Boundary

```svg
<!-- Region boundary -->
<rect x="30" y="30" width="940" height="400" rx="12"
      fill="none" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="8,4"/>
<text x="48" y="50" font-size="11" fill="#fbbf24"
      font-family="JetBrains Mono, monospace">AWS Region: us-east-1</text>
```

## 10. Legend

```svg
<!-- Legend, positioned below all diagram content -->
<g transform="translate(40, 600)">
  <text x="0" y="0" font-size="11" font-weight="600" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Legend</text>

  <!-- Legend item: Process -->
  <rect x="0" y="12" width="14" height="14" rx="3"
        fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1"/>
  <text x="20" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Process</text>

  <!-- Legend item: Module -->
  <rect x="100" y="12" width="14" height="14" rx="3"
        fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1"/>
  <text x="120" y="23" font-size="11" fill="#cbd5e1"
        font-family="JetBrains Mono, monospace">Module</text>

  <!-- Legend items continue horizontally with 100px spacing -->
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
