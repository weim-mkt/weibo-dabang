---
paths:
  - "Quarto/**/*.qmd"
  - "code/**/*.R"
  - "overleaf-weibo-dabang/**/*.tex"
---

# Quality Review & Scoring Rubrics

> **Framing:** Thresholds are **advisory at the harness level**. The `/commit` skill runs `quality_score.py` and halts on failure until the user fixes or explicitly overrides. There is no git pre-commit hook that blocks a direct `git commit` — if you bypass the skill, you bypass the review. "Gate" in this file means "checkpoint enforced by a specific skill," not "repo-wide block."

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Quarto Slides (.qmd)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Compilation failure | -100 |
| Critical | Equation overflow | -20 |
| Critical | Broken citation | -15 |
| Critical | Typo in equation | -10 |
| Major | Text overflow | -5 |
| Major | TikZ label overlap | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 per slide |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed(888) before randomness | -10 |
| Major | Missing figure generation | -5 |

## Manuscript & Response Letter (`overleaf-weibo-dabang/*.tex`)

The Overleaf source compiles on Overleaf, not locally, so we don't gate on `xelatex` here. Instead:

| Severity | Issue | Deduction |
|---|---|---|
| Critical | Cited reference missing from `references2.bib` | -15 |
| Critical | Numeric claim does not match `code/_outputs/` (per `audit-reproducibility`) | -15 per claim |
| Critical | Reviewer comment marked "Addressed" with no concrete change in the manuscript | -20 |
| Major | Em dashes in generated prose (see `writing-style.md`) | -2 each |
| Major | Inconsistent notation vs. `knowledge-base.md` registry | -3 each |
| Minor | Long lines in body text (>120 chars; math allowed per r-code-conventions exception) | -1 each |

## Enforcement (by the /commit skill only)

- **Score < 80:** Halt within `/commit`. List blocking issues. User may override with an explicit natural-language signal ("commit anyway" / "skip quality gate") and a reason — the override is logged in the commit body.
- **Score < 90:** Allow commit within `/commit`, warn. List recommendations.
- **Direct `git commit`** (bypassing the skill): no enforcement. For hard enforcement, install a git pre-commit hook that wraps `quality_score.py`.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Weibo Dabang R port vs. submitted paper)

Mirrors `replication-protocol.md`. `audit-reproducibility` enforces these against `code/_outputs/`:

| Quantity | Tolerance | Rationale |
|---|---|---|
| Integers (N, group counts) | Exact match | No legitimate source of difference |
| Point estimates | Relative diff < 1e-4 | Stata vs `fixest` agree to ~1e-10; allow rounded display |
| Standard errors | Relative diff < 1e-3 | Cluster small-sample DOF correction varies |
| t-statistics | Relative diff < 1e-3 | Follows from SE tolerance |
| P-values | Same significance star | Display rounding |
| Causal-forest CATE quantiles | < 0.01 absolute | `grf` honesty splits depend on `set.seed()` and `RNGkind` |
