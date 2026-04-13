# CSS Layout Migration

## Context

Generated diagrams have alignment and overlap issues because LLMs manually compute SVG absolute coordinates and make arithmetic errors. The solution: use `<foreignObject>` with CSS flexbox for component layout inside SVG, keeping SVG only for arrows/connections.

## Dependency Graph

```
Step 1: design-system.md ─────────────────┐
Step 2: 9 templates (parallel) ───────────┤
Step 3: component-templates.md (arch) ────┤  All can run in parallel
Step 4: layout-rules.md (arch) ──────────┤
Step 5: 4 diagram types (parallel) ───────┤
Step 6: SKILL.md checklist ───────────────┘
         │
         ▼
Step 7: Regenerate examples + screenshots  (depends on all above)
         │
         ▼
Step 8: Update README + test suite         (depends on step 7)
```

## Progress

| Step | Status | Details |
|------|--------|---------|
| 1. design-system.md | DONE | CSS layout rules + foreignObject pattern added |
| 2. 9 templates | DONE | All 9 templates have all 13 CSS classes defined |
| 3. component-templates.md | DONE | Rewritten with foreignObject + CSS |
| 4. layout-rules.md | DONE | Simplified — only layer_y + arrow endpoints |
| 5. 4 diagram types | DONE | All 8 files (components + layout) rewritten with foreignObject + CSS |
| 6. SKILL.md | DONE | Quality Checklist covers foreignObject xmlns, CSS classes, arrow routing, and flowchart `io` SVG polygon rules |
| 7. Regenerate examples | DONE | Existing example JSONs have rendered HTML outputs, and the 4 new style examples now also have PNG previews |
| 8. Update README + tests | DONE | Skill README references valid PNG previews for all 9 styles; export verification passes; full test suite 198/198 passed |

## Task Details

### Phase 1: Reference Docs & Templates — COMPLETE

| Task | Status | Files | Acceptance |
|------|--------|-------|------------|
| 1. Update design-system.md | DONE | `references/design-system.md` | foreignObject pattern documented |
| 2. Update 9 templates | DONE | `assets/template-*.html` (9 files) | Each has `.layer-card`, `.modules`, `.module`, `.module-label`, `.tech-badge`, `.type-*` CSS classes |
| 3. Update component-templates.md | DONE | `references/component-templates.md` | Uses foreignObject + CSS |
| 4. Update layout-rules.md | DONE | `references/layout-rules.md` | Only layer_y + arrow endpoints |
| 5. Update 4 diagram types | DONE | `references/components-{flowchart,mindmap,er,sequence}.md` + `layout-{flowchart,mindmap,er,sequence}.md` (8 files) | Each type has CSS-based templates and simplified layout |
| 6. Update SKILL.md | DONE | `SKILL.md` | Checklist verifies foreignObject xmlns, CSS classes, arrow routing |

### Phase 2: Examples — COMPLETE

Existing example coverage now present:

- `ai-platform.json` -> `images/ai-platform.html` + `images/ai-platform.png`
- `er-blog.json` -> `images/er-blog.html` + `images/er-blog.png`
- `flowchart-ci-cd.json` -> `images/flowchart-ci-cd.html` + `images/flowchart-ci-cd.png`
- `mindmap-learning.json` -> `images/mindmap-learning.html` + `images/mindmap-learning.png`
- `sequence-login.json` -> `images/sequence-login.html` + `images/sequence-login.png`

Style coverage status:

- dark-professional -> PNG example present
- hand-drawn -> PNG example present
- light-corporate -> PNG example present
- blueprint -> PNG example present
- warm-cozy -> PNG example present
- cyberpunk-neon -> PNG example present (`architecture-cyberpunk.png`)
- minimalist -> PNG example present (`architecture-minimalist.png`)
- terminal-retro -> PNG example present (`architecture-terminal.png`)
- pastel-dream -> PNG example present (`architecture-pastel.png`)

Remaining example work:

- optional: regenerate screenshots if visual design changes again

### Phase 3: Docs + Tests — COMPLETE

Completed:

- skill README updated from 6 styles to 9 styles
- README now references valid PNG previews for all 9 styles
- spec/reference docs updated for flowchart `io` polygon rendering rules
- `scripts/export.sh` verified in the current environment
- PNG export works via macOS Quick Look fallback
- PDF export works via macOS Quick Look + `sips` fallback
- smoke-test artifacts produced: `tasks/export-smoke.png`, `tasks/export-smoke.pdf`

Remaining:

- nothing — migration complete
