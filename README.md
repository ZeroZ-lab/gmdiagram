# gmdiagram

Local Claude Code marketplace containing the `architecture-diagram` plugin.

## Structure

- `.claude-plugin/marketplace.json`: Local marketplace index for this repository
- `plugins/architecture-diagram/.claude-plugin/plugin.json`: Installable plugin manifest
- `plugins/architecture-diagram/skills/architecture-diagram/`: The skill payload
- `docs/SPEC.md`: Product notes kept out of the distributed plugin

## Local Use

Add this repository as a local marketplace in Claude Code, then install the `architecture-diagram` plugin from that marketplace.

```bash
/plugin marketplace add .
/plugin install architecture-diagram@gmdiagram-marketplace
```
