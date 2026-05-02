# Replication Targets: Submitted JMR Manuscript (Round 1)

**Paper:** From "Me" to "We": Effect of a Gamified Community Leaderboard on User Content Generation
**Manuscript:** JMR-25-0786
**Source Stata files:** [analysis.do](../data/raw/data and code/analysis.do), [analysis_tweet.do](../data/raw/data and code/analysis_tweet.do)
**Tolerances:** point estimates rel-diff < 1e-4, SEs rel-diff < 1e-3 (per [.claude/rules/replication-protocol.md](../.claude/rules/replication-protocol.md))

Numbers below were extracted from the explore-agent summary of the submitted manuscript. Verify against the actual Overleaf source before treating any cell as the gold standard.

---

## Table 3: Main DiD on content quantity

| Column | DV | ATT (treat × after) | SE | N | Stata anchor |
|---|---|---|---|---|---|
| (1) Overall | log_content_num_in | 0.017 | -- | 3,360,000 | analysis.do:711 |
| (2) Original posts | log_post_original_num_in | 0.003 | -- | 3,360,000 | analysis.do:670 |
| (3) Comments | log_comment_num_in | 0.018 | -- | 3,360,000 | analysis.do:680 |
| (4) Retweets | log_post_transmit_num_in | -- | -- | 3,360,000 | analysis.do:675 |

## Table 4: Quality DiD (length, likes, duplicates)

### Panel A — All content
| Column | DV | ATT | SE | Note |
|---|---|---|---|---|
| (1) Length | log_origin_len_daily | -0.010 | -- | p ≈ 0.081 |
| (2) Likes | log_comment_liked_num_daily | -0.008 | -- | p ≈ 0.019 |
| (3) Duplicates | log_copy_daily | +0.034 | -- | p < 0.001 |

### Panel B — Original posts
| Column | DV | ATT | SE | Note |
|---|---|---|---|---|
| (1) Length | log_origin_len_daily | +0.005 | -- | n.s. |
| (2) Likes | log_post_liked_num_daily | +0.019 | -- | n.s. |
| (3) Duplicates | log_copy_daily | +0.005 | -- | n.s. |

### Panel C — Comments
| Column | DV | ATT | SE | Note |
|---|---|---|---|---|
| (1) Length | log_origin_len_daily | -0.012 | -- | p < 0.05 |
| (2) Likes | log_comment_liked_num_daily | -0.006 | -- | p < 0.05 |
| (3) Duplicates | log_copy_daily | +0.034 | -- | p < 0.05 |

## Table 6: CEM-matched DiD

| Column | DV | ATT | N matched |
|---|---|---|---|
| (1) Original posts | log_post_original_num_in | 0.004 | 3,080,728 |
| (2) Comments | log_comment_num_in | 0.019 | 3,080,728 |

## Table 7: Voting / point contribution

| Column | DV | ATT | SE |
|---|---|---|---|
| (1) Frequency | log_consume_times | 0.051 | -- |
| (2) Points | log_consume_value | 0.187 | -- |

## Table 8: LATE / IV (consume_ind × after instrumented by treat × after)

| Column | DV | ITT | LATE |
|---|---|---|---|
| (1) Comment volume | log_comment_num_in | 0.018 | 0.065 |

---

## Procedure

1. Run `Rscript code/main.R` to populate `code/_outputs/tables/tableNN_*.csv`.
2. Spot-check headline cells:

```bash
Rscript -e 'fread("code/_outputs/tables/table03_quantity.csv")[term == "treat_1:after_1", .(column, estimate, std_error, p_value, n_obs)]'
```

3. Compare against this file row-by-row; record results in `quality_reports/replication_report_round1.md`.
4. SEs are placeholders (--); fill in once verified against the manuscript's Overleaf source.

## Open items before this file is the source of truth

- Pull the **exact** SE / t-stat / N for every Table 3-8 cell from `overleaf-weibo-dabang/main.tex` once the manuscript is opened. Right now only point estimates from the explore-agent summary are recorded.
- Confirm Table 4 Panel A's Stata anchor (overall vs. comment-quality regression set in `analysis_tweet.do`).
- Decide whether Table 5 (event-study) gets per-week target rows or just the visual-parity check (figure overlay).
