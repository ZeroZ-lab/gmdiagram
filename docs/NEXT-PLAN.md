# Plan: gmdiagram Next Phase

> Last updated: 2026-04-13

## Assumptions

1. The current goal is to make `architecture-diagram` release-ready at the documentation, example, and export level, not to add a sixth diagram type.
2. The CSS layout migration is functionally complete, but the repo is not yet operationally complete because examples, screenshots, and export verification are still open.
3. Example coverage and documentation consistency matter more right now than adding new features.
4. It is acceptable to update spec and task documents before more implementation work so the repo has one coherent source of truth.

If any of these are wrong, change them first. The rest of this plan depends on them.

## Objective

Close the gap between the implemented diagram system and the repository’s release artifacts so the plugin can be demonstrated, verified, and maintained without conflicting docs or broken example coverage.

## Why This Phase

The core rendering system is already broad:

- 5 diagram types
- 9 visual styles
- 4 output formats

The remaining risk is not feature breadth. It is operational incompleteness:

- spec and reference docs are starting to diverge
- example assets are incomplete
- export tooling is not verified in the current environment
- README presentation depends on assets that are not guaranteed to exist

This phase should reduce those risks before new scope is added.

## Success Criteria

This phase is complete when all of the following are true:

1. `docs/SPEC.md`, `tasks/migration.md`, `SKILL.md`, and diagram reference docs describe the same rendering model without contradictions.
2. Every example JSON in `assets/examples/` has a corresponding rendered HTML file.
3. Every style has at least one usable example artifact that README can reference without broken links.
4. The PNG export path is either:
   - working end-to-end in the repo, or
   - explicitly documented as environment-dependent with clear failure modes.
5. README examples do not depend on missing files.
6. The migration tracker can be moved to done, or split into a smaller explicit remainder.

## Commands

Repository inspection:

```bash
rg --files .
find tasks -maxdepth 2 -type f | sort
```

Documentation review:

```bash
sed -n '1,260p' docs/SPEC.md
sed -n '1,260p' tasks/migration.md
sed -n '1,260p' architecture-diagram/skills/architecture-diagram/README.md
```

Example inventory:

```bash
find architecture-diagram/skills/architecture-diagram/assets/examples -maxdepth 2 -type f | sort
ls architecture-diagram/skills/architecture-diagram/assets/examples/images
```

Export verification:

```bash
sed -n '1,220p' architecture-diagram/skills/architecture-diagram/scripts/export.sh
architecture-diagram/skills/architecture-diagram/scripts/export.sh <input.html> --format png
architecture-diagram/skills/architecture-diagram/scripts/export.sh <input.html> --format pdf
```

Repo verification:

```bash
git diff --stat
git status --short
```

## Project Structure

Relevant files for this phase:

```text
docs/SPEC.md
docs/NEXT-PLAN.md
tasks/migration.md
README.md
architecture-diagram/README.md
architecture-diagram/skills/architecture-diagram/README.md
architecture-diagram/skills/architecture-diagram/SKILL.md
architecture-diagram/skills/architecture-diagram/references/
architecture-diagram/skills/architecture-diagram/assets/examples/
architecture-diagram/skills/architecture-diagram/scripts/export.sh
```

## Code Style

This phase is doc-heavy and repo-ops-heavy. The standard is:

- Prefer direct, factual language.
- Keep plan items dependency-ordered.
- When a repo constraint is known, write it explicitly.
- Do not claim an asset exists unless it is present in the tree or can be generated in the current environment.

Example:

```md
## Risk

README currently references style preview assets that are not generated in this environment.
Until PNG export is verified, README should link to HTML examples or clearly mark previews as pending.
```

## Testing Strategy

This phase uses three verification levels:

1. Documentation consistency check
   - Compare spec, task tracker, README, and reference docs for contradictions.

2. Asset existence check
   - Confirm every README-linked artifact exists in the repo.

3. Export smoke test
   - Run at least one HTML -> PNG export and one HTML -> PDF export if the environment supports required tools.

If the environment does not support export:

- document the missing dependency
- avoid pretending screenshots were generated
- keep README links pointed at assets that actually exist

## Boundaries

- Always:
  - Update spec/task docs when implementation rules change.
  - Prefer repository truth over stale prose.
  - Verify linked assets exist before referencing them.

- Ask first:
  - Adding new third-party dependencies.
  - Changing plugin packaging or marketplace metadata.
  - Expanding scope beyond examples, export, docs, and release prep.

- Never:
  - Fake screenshot coverage.
  - Add broken README links to “planned” assets.
  - Treat environment-specific export failures as completed work.

## Technical Plan

### Phase 1: Spec and Reference Alignment

Goal: remove contradictions between product spec, migration tracker, and technical references.

Work:

1. Update `docs/SPEC.md` to reflect the actual rendering model, including SVG-native exceptions such as flowchart `io` nodes.
2. Review `tasks/migration.md` and adjust statuses/details to match the current repo state.
3. Re-check `SKILL.md` and reference docs for any remaining stale assumptions from the pre-migration era.

Checkpoint:

- A reviewer can read spec + references without finding conflicting rendering rules.

### Phase 2: Example Coverage Completion

Goal: make the example library representative and usable.

Work:

1. Regenerate the five existing examples still missing rendered outputs.
2. Add one concrete example artifact for each style that still has no usable coverage.
3. Normalize naming so README references are stable and obvious.

Checkpoint:

- Every example JSON has a rendered HTML counterpart.
- Every style has at least one artifact the README can safely reference.

### Phase 3: Export Tooling Hardening

Goal: make asset generation reproducible instead of best-effort.

Work:

1. Fix `scripts/export.sh` issues observed in the current environment.
2. Make dependency failures explicit and actionable.
3. Verify at least one successful export path locally.

Checkpoint:

- Export either works, or fails with a clear documented prerequisite.

### Phase 4: README and Release Closure

Goal: make repo presentation consistent with what actually exists.

Work:

1. Update README example sections to use only verified assets.
2. Replace temporary workarounds with image previews if export is working.
3. Mark `tasks/migration.md` complete or split remaining work into a new follow-up plan.

Checkpoint:

- README has no broken references.
- Migration tracker accurately reflects reality.

## Risks

1. Export tooling may remain blocked by local environment dependencies.
   - Mitigation: treat export verification as an explicit deliverable, not an assumption.

2. Doc drift may continue if spec is not updated alongside reference docs.
   - Mitigation: make spec alignment the first step, not the last.

3. Example generation can sprawl into feature work.
   - Mitigation: only generate missing coverage needed for release readiness.

## Parallel vs Sequential Work

Can run in parallel:

- example inventory
- README asset audit
- spec/reference contradiction scan

Should stay sequential:

1. Spec/reference alignment
2. Example generation
3. Export hardening
4. README finalization

README should stay last because it depends on real asset availability.

## Task Breakdown

- [ ] Task: Align spec with the current rendering model
  - Acceptance: `docs/SPEC.md` matches current reference behavior, including SVG-native flowchart `io` nodes.
  - Verify: manual diff review across `SPEC.md`, `SKILL.md`, and `references/`.
  - Files: `docs/SPEC.md`, `architecture-diagram/skills/architecture-diagram/SKILL.md`, relevant `references/*.md`

- [ ] Task: Reconcile migration tracker with current repository state
  - Acceptance: `tasks/migration.md` statuses reflect what is actually done and what is still blocked.
  - Verify: compare file inventory and open gaps against tracker entries.
  - Files: `tasks/migration.md`

- [ ] Task: Complete missing rendered HTML examples
  - Acceptance: every listed example JSON has a rendered HTML artifact.
  - Verify: file existence check under `assets/examples/` and `assets/examples/images/`.
  - Files: `architecture-diagram/skills/architecture-diagram/assets/examples/`, `.../assets/examples/images/`

- [ ] Task: Establish one valid preview path for each style
  - Acceptance: each style can be referenced from README without dead links.
  - Verify: open/link audit of all README example references.
  - Files: `architecture-diagram/skills/architecture-diagram/README.md`, `.../assets/examples/images/`

- [ ] Task: Harden export script behavior
  - Acceptance: `export.sh` either succeeds for at least one sample or exits with precise prerequisite guidance.
  - Verify: run export smoke test commands and capture result.
  - Files: `architecture-diagram/skills/architecture-diagram/scripts/export.sh`, related docs

- [ ] Task: Finalize README against verified assets
  - Acceptance: README contains no missing example references.
  - Verify: manual link audit and `rg` against referenced filenames.
  - Files: `README.md`, `architecture-diagram/skills/architecture-diagram/README.md`

## Open Questions

1. Do you want the next phase optimized for release polish, or do you want to pivot into adding new diagram capabilities after example coverage is fixed?
2. Should PNG screenshots be treated as required release assets, or is HTML example coverage sufficient for this repository version?
