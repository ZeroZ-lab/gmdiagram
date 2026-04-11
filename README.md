# gmdiagram

`gmdiagram` is a Claude Code plugin marketplace for generating polished diagrams from natural language.

Repository: `https://github.com/ZeroZ-lab/gmdiagram`

## Why gmdiagram

Most AI-generated diagrams are structurally correct but visually weak. `gmdiagram` is built for diagrams that are clear enough for engineering docs and polished enough for articles, slides, and demos.

Current focus:

- Generate diagrams from natural language through the `architecture-diagram` plugin
- Produce single-file outputs that are easy to open, share, and export
- Support multiple diagram types and visual styles without requiring a separate design tool

## What You Get

- **5 diagram types**: Architecture, Flowchart, Mind Map, ER Diagram, Sequence Diagram
- **6 visual styles**: Dark Professional, Hand-Drawn Sketch, Light Corporate, Cyberpunk Neon, Blueprint, Warm Cozy
- **4 output formats**: HTML, SVG, Mermaid, PNG/PDF export
- **Single-file delivery**: inline SVG, embedded styling, no runtime JavaScript required
- **Plugin distribution**: packaged as a Claude Code marketplace with an installable plugin

## Quick Start

### 1. Add the marketplace

```bash
/plugin marketplace add https://github.com/ZeroZ-lab/gmdiagram
```

### 2. Install the plugin

```bash
/plugin install architecture-diagram@gmdiagram-marketplace
```

### 3. Generate a diagram

Example prompts:

```text
Draw an architecture diagram of Chrome's multi-process system

Create a flowchart for a CI/CD pipeline with build, test, and deploy stages

Design an ER diagram for an e-commerce database

画一个微服务架构图，包含 API Gateway、用户服务、订单服务
```

## Example Output Areas

The bundled plugin is designed for:

- System architecture overviews
- Process and decision flowcharts
- Product and knowledge mind maps
- Database ER modeling
- Service interaction and API sequence diagrams

For full feature detail and examples, see:

- [Plugin Overview](plugins/architecture-diagram/README.md)
- [Architecture Diagram Skill README](plugins/architecture-diagram/skills/architecture-diagram/README.md)

## Repository Structure

- `.claude-plugin/marketplace.json`: Marketplace definition for this repository
- `plugins/architecture-diagram/.claude-plugin/plugin.json`: Installable plugin manifest
- `plugins/architecture-diagram/skills/architecture-diagram/`: Skill instructions, templates, schemas, and export scripts
- `docs/SPEC.md`: Product spec and design intent

## Runtime Model

The current plugin follows a structured generation pipeline:

1. Natural language prompt
2. Intermediate structured schema
3. Layout and rendering rules
4. Final HTML / SVG / Mermaid output
5. Optional PNG or PDF export

This keeps output more stable than asking a model to improvise raw diagrams directly.

## Scope

Good fit:

- Engineering documentation
- Technical blog illustrations
- Presentation-ready system visuals
- Quick diagram iteration inside Claude Code

Not the goal:

- Real-time collaborative editing
- Browser-based drag-and-drop diagram editing
- Highly customized brand design systems

## Version

Current marketplace version: `0.1.0`

Current plugin version: `0.1.0`

## Project Status

This repository is in an early packaged stage. The core diagram generation path is present, but the project is still evolving in structure, examples, and distribution ergonomics.

## Contributing

If you want to extend the plugin, start with:

- [docs/SPEC.md](docs/SPEC.md)
- [plugins/architecture-diagram/README.md](plugins/architecture-diagram/README.md)
- [plugins/architecture-diagram/skills/architecture-diagram/SKILL.md](plugins/architecture-diagram/skills/architecture-diagram/SKILL.md)

## Notes

- This repository currently targets Claude Code plugin workflows
- Installation and command syntax assume Claude Code plugin support is available
- License information is not yet declared in the repository
