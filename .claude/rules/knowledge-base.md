---
paths:
  - "Quarto/**/*.qmd"
  - "code/**/*.R"
  - "overleaf-weibo-dabang/**/*.tex"
---

# Knowledge Base: Weibo Dabang JMR R&R

Project-specific notation, variables, design facts, and recurring pitfalls. Read this before authoring or modifying any analysis script, slide, or paper text. Update as the project evolves.

## Notation Registry (paper-side)

| Convention | Definition | Example | Anti-pattern |
|---|---|---|---|
| `treat_i` | Indicator equal to 1 if user `i` is in the leaderboard treatment group, 0 otherwise | `treat_i \in \{0, 1\}` | Do not call this "Treated" or "Group A" in tables; use `\text{Treat}_i` |
| `Post_t` | Indicator equal to 1 for `date >= 2018-06-27` (dabang launch), 0 otherwise | `Post_t \in \{0, 1\}` | Avoid `After_t`; coauthor's Stata uses `after_1` but the paper uses `Post` |
| `Y_{idt}` | Outcome of user `i` in community `d` on day `t` (count, length, likes, etc.) | `Y_{idt} = \text{NumComments}_{idt}` | Drop the `d` index when collapsing to user-day panel |
| `\beta_{DiD}` | Coefficient on `treat_i \times Post_t` in the two-way FE regression | Reported in Tables 3-4 | Do not relabel as ATT until/unless we justify it |
| `q(\cdot)` | Generic quality measure: `Length`, `Likes`, `Duplicate`, optionally Gunning-Fog or stop-word ratio (R3-12) | `q_p` for posts, `q_c` for comments | Do not conflate `Likes` with quality; we treat it as engagement |

## Variable Reference (R / Stata names)

| Stata var (`analysis*.do`) | R var (proposed) | Description | Level |
|---|---|---|---|
| `uid` | `user_id` | Weibo user identifier | user |
| `date` | `date` | Daily date (YYYY-MM-DD) | day |
| `group` | `group` | Treatment-arm label: 1 = treated, 2 = ambiguous (dropped), 3 = control | user |
| `treat_1` | `treat` | `1L` if `group == 1`, `0L` if `group == 3`, `NA` if `group == 2` | user |
| `dabang_launch_date_1` | `launch_date` | `as.Date("2018-06-27")` | scalar |
| `after_1` | `post` | `1L` if `date >= launch_date`, else `0L` | day |
| `sample` | `in_sample` | `1L` if user-day in main analysis window | user-day |
| `post_original_num_in` | `n_posts_orig` | Number of original posts on this day | user-day |
| `post_repost_num_in` | `n_posts_repost` | Number of repost-style posts | user-day |
| `comment_num` (or similar) | `n_comments` | Number of comments | user-day |
| `length_*` | `len_*` | Character length of post / comment text | post or comment |
| `likes_*` | `likes_*` | Likes received | post or comment |
| `duplicate_*` | `is_duplicate_*` | Duplicate flag (within community? across-community? cf. R2-2b) | post or comment |
| `gender == 1` | `male` | Gender indicator | user |
| `birthday` (datetime) -> `birth_year` -> `age` | `age` | `2018 - birth_year` | user |
| `total_post` | `total_post` | Sum of `n_posts_orig` over the analysis window | user |
| `total_post_pre` | `total_post_pre` | Sum of `n_posts_orig` over the pre-treatment window | user |

## Empirical-design Facts

| Fact | Value | Source |
|---|---|---|
| Platform | Sina Weibo (Chinese microblogging) | Paper Section 3 |
| Mechanism | Community ("dabang" / 超级话题) leaderboard introduced to a randomly-selected user subset | Paper Section 3 |
| Treatment date | 2018-06-27 | `analysis.do` line 21 |
| Sample window | ~ 2018-05-28 to 2018-07-22 (~8 weeks) | `analysis_tweet.do` line 30 |
| Placebo dates | 2018-05-27, 2018-04-27 | `analysis.do` |
| Number of users (submitted paper Table 1) | ~60,000 (TBD precise after R replication) | Submitted Table 1 |
| Communities studied | "Superstar" communities only | Paper Section 3; flagged by R3-4 / R2-4 for generalizability |

## Design Principles (revision)

| Principle | Source ask | How to apply |
|---|---|---|
| Replicate before extending | self / `replication-protocol.md` | Numbered R scripts in `code/` mirror `analysis.do` sections; verify each table matches before modifying |
| One SIT dimension at a time | AE-4, AE-7, R1-3 | Pick a single mechanism (e.g., social comparison or recognition), keep it consistent across H1-H6, design moderators that *should* shut it off |
| Multivariate over per-DV regressions | AE-9e, R1-9, R2-3d | Estimate quantity / quality jointly via SUR (`systemfit::systemfit`) or seemingly unrelated GEE; report individual + joint Wald tests |
| PSM as primary, CEM as robustness | AE-9c, R1-7 | `MatchIt::matchit(method="nearest")` (or `WeightIt`) on the candidate-strong covariates; CEM stays in the appendix |
| Long-window pre-trends | AE-9d | Use *all* available pre-treatment user-days (not just 3-4 weeks); event-study chart with shaded 95% CI |
| Spillover-aware ID | AE-9g, R2-3a, R3-1 | Build a "leaderboard-mention" classifier on text; use as control or as exclusion criterion; SUTVA discussion in identification section |
| Heterogeneity over default rank | AE-6, R2-2a | Pre-treatment community rank quartile interacted with `treat x Post`; not just community size |

## Anti-patterns (avoid in this revision)

| Anti-pattern | Why bad | Replacement |
|---|---|---|
| Logging `0` outcomes naively | Returns `-Inf`, drops zero-action user-days, biases volume estimates | `log1p(Y)` or `asinh(Y)`; report both raw and transformed (R2-3b) |
| Using both user FE *and* SE clustered on user | Over-corrects DOF | Pick one; default to two-way FE + cluster on community (AE-9f, R2-3c) |
| Single Length-only quality measure | Length co-moves with Likes (R1-12); not robust | Multi-measure quality (Length, Likes, Duplicate, Gunning-Fog, stop-word ratio) with rationale (R3-12) |
| Beamer-style table-of-coefficients with no normalized effect size | Reviewer R1-11 specifically flagged | Report % change relative to control mean *and* raw coefficient |
| Treating "Number of Original Posts" and "Number of Comments" as having same N as variable-level rows | R1-6b explicitly called this out | Two separate panels (user-day-level vs content-level), explicit N footnote per row |

## R-code Pitfalls (to seed `[LEARN]` entries)

| Pitfall | Detection | Fix |
|---|---|---|
| `data.table` modify-in-place mutates the parent object | Surprising downstream errors | Always `copy()` before destructive `:=` if the input is reused |
| `fixest::feols` reorders factor levels alphabetically | Reference category drift across runs | Set `factor(x, levels = ...)` before passing |
| `MatchIt` discards observations silently | Drops sample size in main analysis without warning | Print `summary(m.out, un = TRUE)` and log discarded N to session log |
| `set.seed()` insufficient with parallel/`future` | CATE estimates non-replicable | Use `RNGkind("L'Ecuyer-CMRG")` and `future::plan(multisession, workers = N, gc = TRUE)` |
| Stata `merge 1:1` warns on key duplicates; `data.table` joins silently produce duplicates | Wrong N after merge | Always `stopifnot(uniqueN(...) == nrow(...))` after a key-defined merge |

## Estimand Registry (revision)

| Estimand | Symbol | Identification assumption | Estimator |
|---|---|---|---|
| ATT on user-day comment volume | `\beta_{DiD}^{cmt}` | Parallel trends; SUTVA holds (or controlled for via leak control) | TWFE `feols(n_comments ~ treat:post \| user_id + date, cluster = ~community_id)` |
| ATT on user-day original posts | `\beta_{DiD}^{post}` | Same | Same form, swap DV |
| Joint quantity / quality system | `(\beta_{quan}, \beta_{qual})` | Same + correlated errors structure | `systemfit::systemfit(method = "SUR", ...)` |
| Heterogeneous treatment effect | `\tau(x_i)` | CIA on `x_i` (community size, default rank, user tenure) | `grf::causal_forest(...)` with honesty + tuning |
| LATE (CEM/PSM-weighted ATT) | `\beta_{DiD}^{att,m}` | Conditional unconfoundedness on `x` | `MatchIt::matchit` then weighted DiD |
