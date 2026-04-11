# ER Diagram — SVG Component Templates

## Entity Box

Each entity renders as a table-like box:

```svg
<!-- Entity: outer border -->
<rect x="X" y="Y" width="W" height="H" rx="6" fill="#0f172a" stroke="[entity-color]" stroke-width="1.5"/>
<!-- Header -->
<rect x="X" y="Y" width="W" height="30" rx="6" fill="[entity-color]"/>
<!-- Header bottom border (square corners at bottom) -->
<rect x="X" y="Y+24" width="W" height="6" fill="[entity-color]"/>
<!-- Header text -->
<text x="X+W/2" y="Y+20" font-size="12" font-weight="600" fill="white" text-anchor="middle">Entity Name</text>
```

### Attribute Row

```svg
<!-- Row separator line -->
<line x1="X" y1="Y+30+rowIndex*22" x2="X+W" y2="Y+30+rowIndex*22" stroke="rgba(255,255,255,0.1)" stroke-width="0.5"/>
<!-- Attribute name -->
<text x="X+12" y="Y+30+rowIndex*22+16" font-size="11" fill="[text-color]">attr_name</text>
<!-- Attribute type (right-aligned) -->
<text x="X+W-12" y="Y+30+rowIndex*22+16" font-size="10" fill="[muted-color]" text-anchor="end">int</text>
```

### PK (Primary Key)

```svg
<text x="X+12" y="Y+30+rowIndex*22+16" font-size="11" fill="[accent-color]" text-decoration="underline" font-weight="600">id</text>
<!-- PK badge -->
<rect x="X+W-42" y="Y+30+rowIndex*22+6" width="20" height="12" rx="2" fill="rgba(251,191,36,0.2)" stroke="#fbbf24" stroke-width="0.5"/>
<text x="X+W-32" y="Y+30+rowIndex*22+15" font-size="7" fill="#fbbf24" text-anchor="middle">PK</text>
```

### FK (Foreign Key)

```svg
<text x="X+12" y="Y+30+rowIndex*22+16" font-size="11" fill="[text-color]" font-style="italic">user_id</text>
<!-- FK badge -->
<rect x="X+W-42" y="Y+30+rowIndex*22+6" width="20" height="12" rx="2" fill="rgba(167,139,250,0.2)" stroke="#a78bfa" stroke-width="0.5"/>
<text x="X+W-32" y="Y+30+rowIndex*22+15" font-size="7" fill="#a78bfa" text-anchor="middle">FK</text>
```

## Relationship Line

### Solid (identifying relationship)

```svg
<line x1="fromX" y1="fromY" x2="toX" y2="toY" stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
```

### Dashed (non-identifying relationship)

```svg
<line x1="fromX" y1="fromY" x2="toX" y2="toY" stroke="#64748b" stroke-width="1.5" stroke-dasharray="6,4" marker-end="url(#arrowhead)"/>
```

### With bend point

```svg
<path d="M fromX,fromY L bendX,fromY L bendX,toY L toX,toY" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#arrowhead)"/>
```

## Cardinality Labels

```svg
<!-- From cardinality (near source) -->
<rect x="fromLabelX-12" y="fromLabelY-8" width="24" height="16" rx="3" fill="[bg-color]" opacity="0.9"/>
<text x="fromLabelX" y="fromLabelY+4" font-size="10" fill="[accent-color]" text-anchor="middle" font-weight="600">1</text>

<!-- To cardinality (near target) -->
<rect x="toLabelX-12" y="toLabelY-8" width="24" height="16" rx="3" fill="[bg-color]" opacity="0.9"/>
<text x="toLabelX" y="toLabelY+4" font-size="10" fill="[accent-color]" text-anchor="middle" font-weight="600">N</text>
```

## Relationship Label (optional)

```svg
<rect x="midX-labelLen*3" y="midY-8" width="labelLen*6" height="16" rx="3" fill="[bg-color]" opacity="0.9"/>
<text x="midX" y="midY+4" font-size="9" fill="#94a3b8" text-anchor="middle">has many</text>
```

## Color Mapping

| Component | Dark Fill | Dark Stroke | Light Fill | Light Stroke |
|-----------|-----------|-------------|------------|--------------|
| Entity header | type color (10% opacity) | type color | type color (10%) | type color |
| Entity body | #0f172a | type color | #ffffff | type color |
| PK badge | rgba(251,191,36,0.2) | #fbbf24 | rgba(180,83,9,0.1) | #b45309 |
| FK badge | rgba(167,139,250,0.2) | #a78bfa | rgba(126,34,206,0.1) | #7e22ce |
| Relationship line | - | #64748b | - | #94a3b8 |
| Cardinality text | - | #94a3b8 | - | #475569 |

## Arrow Markers

```svg
<defs>
  <marker id="er-arrow" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
    <polygon points="0 0, 8 3, 0 6" fill="#64748b"/>
  </marker>
</defs>
```
