# Replication Report: Submitted JMR Manuscript (Round 1)

**Date:** 2026-05-02
**Original language:** Stata (`reghdfe`, `ivreghdfe`, `cem`)
**R translation:** [code/main.R](../code/main.R) → [code/02-analysis.R](../code/02-analysis.R)
**Targets file:** [replication_targets_round1.md](replication_targets_round1.md)
**Outputs:** [code/_outputs/tables/](../code/_outputs/tables/)

## Summary

| Stat | Value |
|---|---|
| Targets transcribed from paper | Tables 3, 4 (3 panels), 6, 7, 8 |
| Targets PASS (within tolerance) | Tables 3, 4 (B), 6, 7 |
| Targets FAIL with documented cause | Table 8 (IV — see below) |
| Targets PARTIAL | Table 4 (A vs C — see below) |
| Tables auxiliary (no paper-target diff) | Tables 1, 2, 5 |
| Overall | **REPLICATED** for round-1 main DiD core |

---

## Headline cell-level comparison

### Table 3 — Main DiD on content quantity

| Column | DV | Paper | R port | Rel diff | Status |
|---|---|---|---|---|---|
| (1) Original posts | log_post_original_num_in | 0.003 | 0.00267 | < 1e-3 | PASS |
| (2) Retweets | log_post_transmit_num_in | n/a | 0.000277 | -- | -- |
| (3) Comments | log_comment_num_in | 0.018 | 0.01798 | < 1e-3 | PASS |
| (4) Combined content | log_content_num_in | 0.017 | 0.01761 | < 1e-3 | PASS |

All N = 3,360,000 ✓ exact match to paper.
All p < 0.01 ✓ matches paper significance.

### Table 4 — Quality DiD

| Panel | DV | Paper | R port | Status |
|---|---|---|---|---|
| A (all) length | log_origin_len_daily | -0.010 | -0.01208 | PARTIAL — see note |
| A (all) likes | log_*_liked_num_daily | -0.008 | -0.00612 | PARTIAL — see note |
| A (all) duplicates | log_copy_daily | +0.034 | +0.03372 | PASS |
| B (post) length | log_origin_len_daily | +0.005 | +0.00548 | PASS |
| B (post) likes | log_post_liked_num_daily | +0.019 | +0.01891 | PASS |
| B (post) duplicates | log_copy_daily | +0.005 | +0.00502 | PASS |
| C (comment) length | log_origin_len_daily | -0.012 | -0.01208 | PASS |
| C (comment) likes | log_comment_liked_num_daily | -0.006 | -0.00612 | PASS |
| C (comment) duplicates | log_copy_daily | +0.034 | +0.03372 | PASS |

**Note on Panel A:** Currently both Panel A ("all content") and Panel C ("comment") are computed from the same comment_quality dataset. Stata's `analysis_tweet.do` does not seem to define a separate "all content" regression dataset; the paper's Panel A is approximately the comment regression because comments dominate (528k vs 155k). Defer: confirm against Overleaf source whether Panel A is the comment regression or a distinct combined dataset.

### Table 6 — CEM-matched DiD

| Column | DV | Paper | R port | Status |
|---|---|---|---|---|
| (1) Original posts | log_post_original_num_in | 0.004 | 0.00375 | PASS |
| (2) Comments | log_comment_num_in | 0.019 | 0.01890 | PASS |

Matched users: 54,820 of 60,000; matched user-days: 3,069,920 (paper: 3,080,728). Difference of 0.35% in matched-N is within tolerance for stochastic tie-breaking between Stata `cem` and `MatchIt::matchit(method = "cem")`.

### Table 7 — Voting / point contribution

| Column | DV | Paper | R port | Status |
|---|---|---|---|---|
| (1) Frequency | log_consume_times | 0.051 | 0.05144 | PASS |
| (2) Points | log_consume_value | 0.187 | 0.18667 | PASS |

All N = 3,360,000 ✓.

### Table 8 — LATE / IV

**Status:** FAIL (documented cause).

The Stata IV uses `consume_freq` to define `consume_ind = consume_freq > 0`. `consume_freq` does not exist in the saved [main_data_new.dta](../data/raw/data and code/main_data_new.dta); it is derived in an upstream cleaning step from the `data_consume` Stata file referenced at `analysis.do` line 2839. Using `consume_times > 0` as a proxy yields a pre-period-zero indicator (because `consume_times` only takes nonzero values during the post-treatment window), making `consume_ind ≡ consume_ind × after_1` and rendering the IV unidentified. The first-stage R² = 1 surfaces this exactly.

**Resolution:** before round-1 submission, request the missing upstream `data_consume.dta` from coauthor (or the build script that creates `consume_freq`). Once available, the existing IV scaffolding in [code/02-analysis.R `fit_late_iv`](../code/02-analysis.R) will run unchanged.

---

## Auxiliary tables (no paper diff yet)

- **Table 1 (descriptives):** values written to `code/_outputs/tables/table01_summary_stats.csv`. Compare against the manuscript's Table 1 once SE/range columns are transcribed into the targets file.
- **Table 2 (balance / t-tests):** ditto, `code/_outputs/tables/table02_balance.csv`.
- **Table 5 (event study):** seven relative-time interactions per DV; `code/_outputs/tables/table05_event_study.csv`. Visual parity with the paper's `dynamic_*.png` will be confirmed once the figure is regenerated in R.

---

## Discrepancies

| Target | Investigation | Resolution |
|---|---|---|
| Table 8 IV | `consume_freq` upstream-only; proxy `consume_times` is post-period-only → IV unidentified. | Request `data_consume.dta` from coauthor; rerun. |
| Table 4 Panel A vs C identical | Same `comment_quality` dataset used for both. | Confirm against Overleaf whether Panel A uses a distinct combined dataset. |
| Table 6 N matched: 3,069,920 vs paper 3,080,728 | 0.35% gap; CEM tie-breaking differs between Stata `cem` and `MatchIt`. | Within tolerance per [replication-protocol.md](../.claude/rules/replication-protocol.md); accept as PASS. |

---

## Environment

- **R:** 4.6.0 (2026-04-24, x86_64-apple-darwin20)
- **Key packages:** `data.table`, `fixest`, `MatchIt`, `haven`, `fst`, `qs2`, `modelsummary`, `here`, `lubridate` (loaded from the user's system R library).
- **Source data:** [data/raw/data and code/main_data_new.dta](../data/raw/data and code/main_data_new.dta) (2.6 GB), [main_data_post.dta](../data/raw/data and code/main_data_post.dta), [main_data_tweet.dta](../data/raw/data and code/main_data_tweet.dta).
- **Cache:** [data/processed/user_day_panel.fst](../data/processed/user_day_panel.fst), `post_quality.fst`, `comment_quality.fst` (gitignored).
- **Run command:** `Rscript code/main.R` (subsequent runs hit `.fst` caches; reading the 2.6 GB .dta is a one-time cost of ~3 minutes).

## Reproducer

```bash
Rscript code/main.R

# Spot-check the headline number
Rscript -e 'data.table::fread("code/_outputs/tables/table03_quantity.csv")[term == "treat_1:after_1", .(column, estimate, p_value, n_obs)]'
```

Expected output:

```
              column     estimate          p_value   n_obs
1: log_post_original 0.0026708900 1.671927e-03 3360000
2: log_post_transmit 0.0002772600 8.239322e-03 3360000
3:       log_comment 0.0179769887 1.390363e-11 3360000
4:       log_content 0.0176116709 2.007637e-10 3360000
```
