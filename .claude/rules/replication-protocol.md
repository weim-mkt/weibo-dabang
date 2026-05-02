---
paths:
  - "code/**/*.R"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any R code:

- [ ] Read the paper's replication README
- [ ] Inventory replication package: language, data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main ATT | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
```

- [ ] Store targets in `quality_reports/replication_targets.md` (one file per submission round) or as `code/_outputs/replication_targets.rds`

---

## Phase 2: Translate & Execute

- [ ] Follow `r-code-conventions.md` for all R coding standards
- [ ] Translate line-by-line initially -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save intermediate results: `fst::write_fst()` for tabular data, `qs2::qs_save()` for model objects

### Stata to R Translation Pitfalls (Weibo Dabang project)

| Stata | R | Trap |
|---|---|---|
| `reg y x, cluster(id)` | `fixest::feols(y ~ x, cluster = ~id)` | Stata clusters df-adjust differently from `lfe`/`sandwich`. `fixest` matches Stata's default; double-check for unbalanced panels. |
| `reghdfe y x, absorb(uid date) cluster(uid)` | `fixest::feols(y ~ x \| uid + date, cluster = ~uid)` | Stata `reghdfe` and `fixest` agree to ~1e-10 on point estimates; SE may differ at the 4th decimal because of small-sample DOF corrections. |
| `xi i.var` | `factor(var)` in formula or `model.matrix(~ factor(var))` | R drops the first level by default; Stata drops the smallest. Set `contrasts` or use the same reference category. |
| `egen total = sum(x), by(id)` | `data.table: dt[, total := sum(x), by = id]` or `dplyr::group_by(id) %>% mutate(total = sum(x))` | Stata `sum` ignores missings by default; R `sum()` returns `NA`. Use `na.rm = TRUE` explicitly to match. |
| `egen rank = rank(x), by(id)` | `data.table::frank(x, ties.method = "min")` inside `by = id` | Default tie-breaking differs (`min` vs `average`). Always pass `ties.method` explicitly. |
| `winsor2 x, replace cuts(1 99)` | `DescTools::Winsorize(x, probs = c(0.01, 0.99), na.rm = TRUE)` | Stata defaults to `cuts(1 99)` and modifies in place; R returns a new vector. |
| `gen y = log(x)` with `x == 0` | `log(x)`, `log1p(x)`, or `asinh(x)` | Stata returns missing on `log(0)`; R returns `-Inf`. Choose `log1p` or `asinh` and document — relevant to R2 comment 3b on zero handling. |
| `date("Jun 27 2018","MDY")` | `lubridate::mdy("Jun 27 2018")` or `as.Date("2018-06-27")` | Watch for time-zone shift if column is `POSIXct`. Force UTC with `lubridate::with_tz`. |
| `probit` for propensity score | `glm(... , family = binomial(link = "probit"))` | The Stata `pscore`/`teffects` ecosystem defaults to logit in some commands and probit in others; mirror the original do-file's link function. |
| `bootstrap, reps(999) seed(42)` | `boot::boot(..., R = 999)` with `set.seed(42)` | Match seed, reps, and bootstrap type (case vs cluster) exactly. |
| `tabstat x, stats(mean sd p1 p99)` | `data.table::dcast` or `gtsummary::tbl_summary` | Verify percentile interpolation (Stata uses type 2; R `quantile` defaults to type 7). |

---

## Phase 3: Verify Match

### Tolerance Thresholds (Weibo Dabang R port vs. submitted-paper Tables 1–8)

| Type | Tolerance | Rationale |
|---|---|---|
| Integers (N, group counts, observations) | Exact match | No legitimate source of difference |
| Point estimates | Relative diff < 1e-4 | Stata and `fixest` agree to ~1e-10 on point estimates; allow rounding shown in paper |
| Standard errors | Relative diff < 1e-3 | DOF / cluster small-sample adjustment may diverge at the 4th decimal |
| t-statistics | Relative diff < 1e-3 | Follows from SE tolerance |
| P-values | Same significance star | Exact p can differ in the 4th decimal |
| Percentages / proportions | < 0.1pp | Display rounding |
| Causal-forest CATE quantiles | < 0.01 in absolute terms | `grf` random seed must match; honesty splits change with `set.seed()` |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample size, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/replication_report_<round>.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [Stata/R/etc.]
**R translation:** [script path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- R version, key packages (with versions), data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with course-specific modifications (different estimators, new figures, etc.)
- [ ] Each extension builds on the verified baseline

---

## Enforcement

This rule is enforced by the [`/audit-reproducibility`](../skills/audit-reproducibility/SKILL.md) skill. It parses numeric claims from a manuscript, locates matching values in `code/_outputs/` (or the user-specified outputs directory), and compares against the tolerance thresholds above. Run it:

- **Before submission** — `/audit-reproducibility path/to/manuscript.tex`
- **Before releasing a replication package** — same invocation; aim for zero FAILs.
- **As a pre-commit gate** — wire into `/commit` when the diff touches both manuscript and analysis files.

The skill exits 1 on any tolerance violation, so it integrates cleanly with quality gates.
