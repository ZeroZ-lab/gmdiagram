# gmdiagram

`gmdiagram` is a plugin repository for generating polished diagrams from natural language in both Claude Code and Codex.

Repository: `https://github.com/ZeroZ-lab/gmdiagram`

## Why gmdiagram

Most AI-generated diagrams are structurally correct but visually weak. `gmdiagram` is built for diagrams that are clear enough for engineering docs and polished enough for articles, slides, and demos.

Current focus:

- Generate diagrams from natural language through the `architecture-diagram` plugin
- Produce single-file outputs that are easy to open, share, and export
- Support multiple diagram types and visual styles without requiring a separate design tool

## Features

- **5 diagram types**: Architecture, Flowchart, Mind Map, ER Diagram, Sequence Diagram
- **6 visual styles**: Dark Professional, Hand-Drawn Sketch, Light Corporate, Cyberpunk Neon, Blueprint, Warm Cozy
- **4 output formats**: HTML, SVG, Mermaid, PNG/PDF export
- **Single-file delivery**: inline SVG, embedded styling, no JavaScript required

## Quick Start

### Claude Code

```bash
# 1. Add the marketplace
/plugin marketplace add ZeroZ-lab/gmdiagram

# 2. Install the plugin
/plugin install architecture-diagram@gmdiagram-marketplace
```

### Codex

For Codex, use the repo as a local plugin source. This repository now includes:

- `architecture-diagram/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json`

If you are using this repo locally, point Codex at the repository root so it can discover the marketplace and plugin metadata.

Then ask the agent to create a diagram:

```text
Draw an architecture diagram of Chrome's multi-process system

Create a flowchart for a CI/CD pipeline with build, test, and deploy stages

画一个微服务架构图，包含 API Gateway、用户服务、订单服务
```

For full documentation including examples, visual style reference, and output format details, see the [Architecture Diagram Skill README](architecture-diagram/skills/architecture-diagram/README.md).

## Repository Structure

- `.claude-plugin/marketplace.json` — Marketplace definition
- `.agents/plugins/marketplace.json` — Codex local marketplace definition
- `architecture-diagram/` — Installable plugin
  - `.claude-plugin/plugin.json` — Claude plugin manifest
  - `.codex-plugin/plugin.json` — Codex plugin manifest
  - `skills/architecture-diagram/` — Skill instructions, templates, schemas, export scripts
- `docs/SPEC.md` — Product specification

## Version

- Marketplace: `0.1.2`
- Plugin: `0.1.2`

## License

MIT
