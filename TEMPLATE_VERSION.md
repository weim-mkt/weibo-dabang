# Workflow Template Version

This project's `.claude/`, `CLAUDE.md`, `MEMORY.md`, `scripts/`, `templates/`, and `.githooks/` were copied from the [claude-code-my-workflow](https://github.com/weim-mkt/claude-code-my-workflow) fork (originally from [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)) and then customized for this project.

## Snapshot

| Field | Value |
|---|---|
| Source repo | `git@github.com:weim-mkt/claude-code-my-workflow.git` (user's fork) |
| Upstream | `pedrohcgs/claude-code-my-workflow` |
| Commit at copy time | `df658fb911a0db72626e663e27288bd692aadd5f` |
| Commit subject | `Merge pull request #5 from weim-mkt/chore/local-only-commit-default` |
| Commit date | `2026-04-26` |
| Copy date | `2026-05-02` |
| Local symlink | [`claude-code-my-workflow/`](claude-code-my-workflow/) → `/Users/weimiao/data/github/claude-code-my-workflow` |

## Pulling future updates

The symlink at [`claude-code-my-workflow/`](claude-code-my-workflow/) stays attached to the upstream fork so updates can flow in. The recommended cadence is:

```bash
# 1. Refresh the fork
cd /Users/weimiao/data/github/claude-code-my-workflow
git pull origin main

# 2. Diff what's new since last sync
git log --oneline df658fb..HEAD

# 3. Cherry-pick or copy in changes that apply to this project
#    Most new files / rule edits in claude-code-my-workflow/.claude/rules/,
#    .claude/skills/, .claude/hooks/, scripts/, templates/ can be copied
#    selectively. Beamer/teaching scaffolding (single-source-of-truth,
#    beamer-quarto-sync, no-pause-beamer, compile-latex, create-lecture,
#    translate-to-quarto, qa-quarto, extract-tikz, new-diagram, pedagogy-review,
#    slide-excellence, check-palette-sync, check-tikz-prevention, tikz-snippets/)
#    is intentionally omitted from this project — see the install plan at
#    /Users/weimiao/.claude/plans/woolly-doodling-mitten.md for the full
#    exclude list and rationale.

# 4. Update the snapshot above to the new commit SHA + date.
```

## Customizations specific to this project

The following files diverge from upstream and **should not** be blindly overwritten on sync:

- `CLAUDE.md` — fully rewritten for the JMR R&R revision
- `MEMORY.md` — project-seeded with empirical-design facts and reviewer-team map
- `.claude/rules/replication-protocol.md` — Stata→R translation pitfalls + tolerance thresholds
- `.claude/rules/knowledge-base.md` — Weibo/dabang notation registry (renamed from `knowledge-base-template.md`)
- `.claude/rules/quality-gates.md` — Beamer scoring row removed
- `.claude/rules/verification-protocol.md` — Beamer compile section removed; R-script verification block added
- `.claude/rules/content-invariants.md` — INV-6 (Beamer overlays) removed
- `.claude/rules/meta-governance.md` — clarified as working downstream project
- `.claude/rules/cross-artifact-review.md` — trigger paths extended to `overleaf-weibo-dabang/**`
- `.claude/hooks/check-code-path.sh` — EXCLUDES extended to skip `overleaf-weibo-dabang/`
- `.claude/WORKFLOW_QUICK_REF.md` — non-negotiables filled in for this project
- `scripts/quality_score.py` — Beamer scoring branch removed
- `scripts/validate-setup.sh` — xelatex/MacTeX checks removed
- `templates/response-to-referees.md` — JMR-specific structure (SE → AE → R1 → R2 → R3)
- `.gitignore` — merged with project-specific entries

When syncing upstream changes that touch any of these, hand-merge rather than overwriting.
