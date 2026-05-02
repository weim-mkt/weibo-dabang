# Workflow Quick Reference — Weibo Dabang JMR R&R

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "`treat_1` vs `group == 1` give different N because of `group == 2`. Drop it as in `analysis.do`?"
- **Replication edge case:** "DiD point estimate matches to 1e-5 but SE differs by 4%. Investigate or accept?"
- **Submodule operations:** "Edit lives in `overleaf-weibo-dabang/`. Commit and push from inside the submodule, or stage in main repo first?"
- **Scope question:** "Also refactor utils while here, or focus on the AE-9c PSM ask?"

---

## I Just Execute When

- Code fix is obvious (bug, lint, pattern application)
- Verification (tolerance checks against `code/_outputs/`, R script reruns)
- Documentation updates (session logs, plan files)
- Plotting (using project theme + 300 dpi)
- Quarto rendering (after you approve the deck content)

---

## Quality Gates (advisory, enforced by `/commit`)

| Score | Action |
|---|---|
| >= 80 | Ready to commit |
| 80–89 | Commit with note on remaining issues |
| 90+ | Submit-ready (push to coauthor / Overleaf) |
| < 80 | Fix blocking issues first |

---

## Non-Negotiables (this project)

- **Path convention:** `here::here(...)` in every R script; project root anchored via `here::i_am("CLAUDE.md")`. No absolute paths except the documented `data/raw/` symlink.
- **Seed convention:** `set.seed(888)` immediately before each randomness step (matching, bootstrap, CATE fit). Not once at the top. For parallel work also set `RNGkind("L'Ecuyer-CMRG")`.
- **Figure standards:** publication-ready PDF (`device = "cairo_pdf"`) for paper figures; PNG at 300 dpi for slide thumbnails. Project theme on every ggplot. No default ggplot2 gray background.
- **Color palette:** *deferred* until a Quarto theme is established. Until then, use base `viridis` for sequential / `Okabe-Ito` for categorical.
- **Tolerance thresholds:** point estimates rel. diff < 1e-4; SEs rel. diff < 1e-3; integers exact. Causal-forest CATE quantiles within 0.01 absolute. See [`replication-protocol.md`](rules/replication-protocol.md).
- **Writing style:** no em dashes; replication before extension; explicit `[LEARN]` entries on correction.
- **Submodule discipline:** `overleaf-weibo-dabang/` edits go through `cd overleaf-weibo-dabang && git ...`. Bumping the submodule pointer is a separate, intentional commit in the parent repo.

---

## Preferences

- **Visual:** publication-ready by default (300 dpi, vector for paper, raster for slides). No placeholder figures committed.
- **Reporting:** concise bullets with key numbers and file paths; details available on request.
- **Session logs:** always — post-plan, incremental during long tasks, end-of-session summary.
- **Replication strictness:** flag any near-miss above the tolerance band; investigate before accepting.
- **Reviewer responses:** terse and concrete. Each response cites the specific change in the manuscript ("page X, line Y, paragraph beginning '…'") and the analysis output that supports it.
- **Cross-artifact review:** run on every R&R round before pushing the manuscript bump.

---

## Exploration Mode

For experimental work (alternative quality measures, new heterogeneity dimensions, NLP feature engineering), use the **Fast-Track** workflow:

- Work in `explorations/` folder.
- 60/100 quality threshold (vs. 80/100 for production).
- No plan needed — just a research-value check (2 min).
- See [`.claude/rules/exploration-fast-track.md`](rules/exploration-fast-track.md).

Successful experiments graduate into `code/` via the regular plan-first workflow.

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done. For the next session, the natural starting point is `/data-analysis` to scaffold the R replication of the submitted Tables 1–8.
