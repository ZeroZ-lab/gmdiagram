# gm-data-chart plugin

Installable plugin that exposes the `gm-data-chart` skill for both Claude Code and Codex.

Source repository: `https://github.com/ZeroZ-lab/gmdiagram`

## Install

### Claude Code

```bash
/plugin marketplace add ZeroZ-lab/gmdiagram
/plugin install gm-data-chart@gmdiagram-marketplace
```

### Codex

This plugin directory now includes a Codex manifest at `.codex-plugin/plugin.json`.

If you use the repository locally, Codex can discover it through the repo-level marketplace file:

- `.agents/plugins/marketplace.json`

The plugin payload is shared across both environments:

- `skills/`
- `assets/`

## Documentation

- [Skill README](skills/gm-data-chart/README.md) — Full feature documentation, examples, and usage guide
- [SKILL.md](skills/gm-data-chart/SKILL.md) — Core instructions read by Claude when the skill is triggered
