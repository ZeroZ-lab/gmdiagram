# gmdiagram

`gmdiagram` is a plugin repository for generating polished diagrams and data charts from natural language in both Claude Code and Codex.

Repository: `https://github.com/ZeroZ-lab/gmdiagram`

## Why gmdiagram

Most AI-generated diagrams are structurally correct but visually weak. `gmdiagram` is built for diagrams that are clear enough for engineering docs and polished enough for articles, slides, and demos.

Current focus:

- Generate diagrams from natural language through the `gm-architecture` plugin
- Generate data charts from natural language through the `gm-data-chart` plugin
- Produce single-file outputs that are easy to open, share, and export
- Support multiple diagram types and visual styles without requiring a separate design tool

## Features

- **8 diagram types**: Architecture, Flowchart, Mind Map, ER Diagram, Sequence Diagram, Gantt, UML Class, Network
- **9 chart types**: Bar, Pie/Donut, Line, Area, Scatter, Radar, Funnel, Bubble, Table (via `data-chart` skill)
- **12 visual styles**: Dark Professional, Hand-Drawn Sketch, Light Corporate, Cyberpunk Neon, Blueprint, Warm Cozy, Minimalist, Terminal Retro, Pastel Dream, Notion, Material, Glassmorphism
- **4 output formats**: HTML, SVG, Mermaid, PNG/PDF export
- **Single-file delivery**: inline SVG, embedded styling, no JavaScript required

## Quick Start

### Claude Code

```bash
# 1. Add the marketplace
/plugin marketplace add ZeroZ-lab/gmdiagram

# 2. Install the plugins
/plugin install gm-architecture@gmdiagram-marketplace
/plugin install gm-data-chart@gmdiagram-marketplace
```

### Codex

For Codex, use the repo as a local plugin source. This repository now includes:

- `gm-architecture/.codex-plugin/plugin.json`
- `gm-data-chart/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json`

If you are using this repo locally, point Codex at the repository root so it can discover the marketplace and plugin metadata.

Then ask the agent to create a diagram:

```text
Draw an architecture diagram of Chrome's multi-process system

Create a flowchart for a CI/CD pipeline with build, test, and deploy stages

画一个微服务架构图，包含 API Gateway、用户服务、订单服务
```

For full documentation including examples, visual style reference, and output format details, see:
- [GM Architecture Skill README](gm-architecture/skills/gm-architecture/README.md)
- [GM Data Chart Skill README](gm-data-chart/skills/gm-data-chart/README.md)

## Repository Structure

- `.claude-plugin/marketplace.json` — Marketplace definition
- `.agents/plugins/marketplace.json` — Codex local marketplace definition
- `gm-architecture/` — Architecture diagram plugin
  - `.claude-plugin/plugin.json` — Claude plugin manifest
  - `.codex-plugin/plugin.json` — Codex plugin manifest
  - `skills/gm-architecture/` — Diagram skill instructions, templates, schemas, export scripts
- `gm-data-chart/` — Data chart plugin
  - `.claude-plugin/plugin.json` — Claude plugin manifest
  - `.codex-plugin/plugin.json` — Codex plugin manifest
  - `skills/gm-data-chart/` — Chart skill instructions, schemas, render rules
- `docs/SPEC.md` — Product specification

## Version

- Marketplace: `0.5.0`
- Plugin: `0.5.0`

## License

MIT
