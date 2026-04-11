# Sequence Diagram — SVG Component Templates

## Actor Box (Participant)

```svg
<rect x="X-W/2" y="20" width="W" height="36" rx="4" fill="#0f172a" stroke="#22d3ee" stroke-width="1.5"/>
<text x="X" y="43" font-size="12" font-weight="500" fill="white" text-anchor="middle">Actor Label</text>
```

## Actor Stick Figure

```svg
<!-- Head -->
<circle cx="X" cy="12" r="6" fill="none" stroke="#22d3ee" stroke-width="1.5"/>
<!-- Body -->
<line x1="X" y1="18" x2="X" y2="32" stroke="#22d3ee" stroke-width="1.5"/>
<!-- Arms -->
<line x1="X-8" y1="24" x2="X+8" y2="24" stroke="#22d3ee" stroke-width="1.5"/>
<!-- Legs -->
<line x1="X" y1="32" x2="X-6" y2="42" stroke="#22d3ee" stroke-width="1.5"/>
<line x1="X" y1="32" x2="X+6" y2="42" stroke="#22d3ee" stroke-width="1.5"/>
```

## Lifeline

```svg
<line x1="X" y1="56" x2="X" y2="BOTTOM" stroke="#64748b" stroke-width="1" stroke-dasharray="6,4"/>
```

## Sync Message (solid arrow)

```svg
<defs>
  <marker id="seq-arrow-solid" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
    <polygon points="0 0, 8 3, 0 6" fill="#e2e8f0"/>
  </marker>
</defs>
<line x1="FROM_X" y1="Y" x2="TO_X" y2="Y" stroke="#e2e8f0" stroke-width="1.5" marker-end="url(#seq-arrow-solid)"/>
<text x="(FROM_X+TO_X)/2" y="Y-6" font-size="10" fill="#94a3b8" text-anchor="middle">Message Label</text>
```

## Async Message (open arrow)

```svg
<defs>
  <marker id="seq-arrow-open" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
    <polyline points="0 0, 8 3, 0 6" fill="none" stroke="#e2e8f0" stroke-width="1"/>
  </marker>
</defs>
<line x1="FROM_X" y1="Y" x2="TO_X" y2="Y" stroke="#e2e8f0" stroke-width="1.5" marker-end="url(#seq-arrow-open)"/>
```

## Return Message (dashed arrow)

```svg
<line x1="FROM_X" y1="Y" x2="TO_X" y2="Y" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="6,4" marker-end="url(#seq-arrow-open)"/>
```

## Self-Message (recursive call)

```svg
<path d="M X,Y L X+30,Y L X+30,Y+20 L X,Y+20" fill="none" stroke="#e2e8f0" stroke-width="1.5" marker-end="url(#seq-arrow-solid)"/>
```

## Activation Box

```svg
<rect x="X-6" y="TOP_Y" width="12" height="HEIGHT" rx="2" fill="rgba(34,211,238,0.15)" stroke="#22d3ee" stroke-width="1"/>
```

## Fragment Frame

```svg
<!-- Frame rect -->
<rect x="X" y="Y" width="W" height="H" rx="4" fill="none" stroke="#64748b" stroke-width="1"/>

<!-- Label tab (pentagon) -->
<path d="M X,Y L X,Y+20 L X+50,Y+20 L X+60,Y+10 L X+60,Y Z" fill="rgba(100,116,139,0.2)" stroke="#64748b" stroke-width="1"/>

<!-- Label text -->
<text x="X+8" y="Y+15" font-size="10" font-weight="600" fill="#cbd5e1">alt</text>

<!-- Condition text -->
<text x="X+12" y="Y+34" font-size="9" fill="#94a3b8">[valid credentials]</text>
```

## Alt Else Divider

```svg
<line x1="X" y1="ELSE_Y" x2="X+W" y2="ELSE_Y" stroke="#64748b" stroke-width="1" stroke-dasharray="6,4"/>
<text x="X+8" y="ELSE_Y+14" font-size="9" fill="#94a3b8">[else: invalid]</text>
```

## Note Box

```svg
<rect x="X" y="Y" width="W" height="24" rx="3" fill="rgba(251,191,36,0.1)" stroke="#fbbf24" stroke-width="0.8"/>
<text x="X+W/2" y="Y+16" font-size="9" fill="#fbbf24" text-anchor="middle">Note text</text>
```

## Color Mapping per Style

| Element | Dark | Blueprint | Warm |
|---------|------|-----------|------|
| Actor box stroke | #22d3ee | #88c0d0 | #b45309 |
| Lifeline | #64748b | #4c566a | #a89984 |
| Sync arrow | #e2e8f0 | #eceff4 | #3c3836 |
| Return arrow | #94a3b8 | #81a1c1 | #78716c |
| Fragment border | #64748b | #4c566a | #d5c4a1 |
| Activation fill | rgba(34,211,238,0.15) | rgba(136,192,208,0.15) | rgba(180,83,9,0.1) |
