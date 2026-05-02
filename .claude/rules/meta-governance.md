# Meta-Governance: This Project's Identity

**This repository is a working downstream project, not a public template.** The workflow infrastructure here was copied from [`pedrohcgs/claude-code-my-workflow`](https://github.com/pedrohcgs/claude-code-my-workflow) (via the user's [`weim-mkt/claude-code-my-workflow`](https://github.com/weim-mkt/claude-code-my-workflow) fork) and customized for the JMR R&R revision of the Weibo dabang study. See [TEMPLATE_VERSION.md](../../TEMPLATE_VERSION.md) for the version pin.

The dual-identity language inherited from upstream (template vs. working project) does not apply here: this is exclusively a working project.

---

## Decision Framework

When creating or modifying content, ask:

### "Is this PROJECT-SPECIFIC or PORTABLE?"

**PROJECT-SPECIFIC (commit to this repo):**
- Stata-to-R translation pitfalls observed in `analysis.do`
- Variable-name conventions for the Weibo dataset
- Reviewer-comment tracker entries
- AE/Rn-driven design decisions and their rationale
- Quality thresholds tuned for this paper's tolerances
- Project-specific anti-patterns

**PORTABLE (also push back upstream as a fork update):**
- Improvements to the workflow infrastructure itself (rules, skills, hooks, scripts)
- Bug fixes in shipped scripts (`quality_score.py`, `check-skill-integrity.py`, etc.)
- Generic `[LEARN]` entries that would help any forker

When you make a portable improvement, note it in the active session log so it can be cherry-picked back to the upstream fork at sync time.

---

## Memory Management

### `MEMORY.md` (root, committed)

**Purpose:** Cross-session context for this project + a small set of generic `[LEARN]` entries.

**Layered structure:**
- Project Context section: paper metadata, design facts, reviewer team, methodological backlog. Updated as work proceeds.
- Generic `[LEARN:category]` entries inherited from the upstream template. Append corrections; the most recent at the bottom.

**Size limit:** Keep under ~200 lines. Lines past 200 are truncated by the harness.

### `.claude/state/personal-memory.md` (gitignored, optional)

Use only if there is genuinely machine-specific information you do not want committed (e.g., a personal Dropbox path that differs across collaborator machines).

In practice for this project, the path is centralized: the `data/raw -> /Volumes/dataHP/Dropbox/Project/Sina Dabang/data` symlink is the only machine-specific reference, and it lives in `.gitignore` (the symlink itself is ignored). No two-tier MEMORY system is required.

---

## Dogfooding: Following the Workflow

These habits are non-negotiable in this project.

### Plan-First Workflow
- Enter plan mode for non-trivial tasks (>3 files, >1 hour, multi-step).
- Save plans to `quality_reports/plans/YYYY-MM-DD_description.md`.
- Don't skip planning for "quick fixes" that turn into multi-hour tasks.

### Spec-Then-Plan
- Create requirements specs in `quality_reports/specs/` for ambiguous tasks.
- Use MUST/SHOULD/MAY framework with CLEAR/ASSUMED/BLOCKED clarity status.
- Don't jump straight to planning when requirements are fuzzy.

### Quality Gates
- Run `scripts/quality_score.py` (also wired into `/commit`) on changed files.
- Nothing ships below 80/100 without an explicit override + reason in the commit body.

### Replication Before Extension
- Port and verify coauthor's Stata results in R *before* layering reviewer-driven changes.
- See [`replication-protocol.md`](replication-protocol.md) for tolerance thresholds and the report template.

### Submodule Discipline
- Edits to `overleaf-weibo-dabang/` are committed and pushed from inside the submodule.
- Bumping the parent-repo submodule pointer is an explicit, separate commit.
- Never `git add overleaf-weibo-dabang/some/file.tex` from the parent repo.

### Context Survival
- Update `MEMORY.md` with `[LEARN]` entries after sessions.
- Save active plans to disk before compression.
- Keep session logs current (last 10 minutes' work).
- Don't rely solely on conversation history; it compresses.

---

## Quick Reference Table

| Content Type | Commit to repo? | Where It Goes | Notes |
|---|---|---|---|
| Project-specific learnings | Yes | `MEMORY.md` (Project Context) | Updated as project evolves |
| Generic `[LEARN]` entries | Yes | `MEMORY.md` (bottom) | Cherry-pick interesting ones to upstream fork |
| Reviewer-comment tracker | Yes | `quality_reports/plans/jmr-r1-tracker.md` | One row per AE/Rn ask |
| Plans, specs, session logs | Yes | `quality_reports/{plans,specs,session_logs}/` | One per session/task |
| Decision records | Yes | `quality_reports/decisions/` | When a non-obvious methodological choice is made |
| Merge / submission reports | Yes | `quality_reports/merges/` | At each major checkpoint |
| Workflow infrastructure | Yes | `.claude/`, `scripts/`, `templates/` | Customized for this project; cherry-pick portable changes upstream |
| Local settings | No | `.claude/settings.local.json` | Gitignored |
| Session state | No | `.claude/state/` | Gitignored |
| Build artifacts | No | `.aux`, `.log`, `_outputs/` | Gitignored |
| Raw data | No | `data/raw/` (symlink) | Symlink itself is ignored; the Dropbox content is the source of truth |

---

## When to Sync from Upstream

The symlink at `claude-code-my-workflow/` keeps the upstream fork accessible. To pull updates:

1. `git -C claude-code-my-workflow pull origin main`
2. Diff: `git -C claude-code-my-workflow log --oneline df658fb..HEAD` (replace SHA with the one in [TEMPLATE_VERSION.md](../../TEMPLATE_VERSION.md))
3. Cherry-pick or copy in changes that apply, **excluding** Beamer/teaching-only files (see [TEMPLATE_VERSION.md](../../TEMPLATE_VERSION.md) for the full exclude list).
4. Update [TEMPLATE_VERSION.md](../../TEMPLATE_VERSION.md) with the new commit SHA + date.

Don't pull blindly: rules and skills are customized in this project and a naive overwrite will lose project-specific edits.
