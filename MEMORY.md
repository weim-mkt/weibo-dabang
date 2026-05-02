# Project Memory

Cross-session context for the Weibo Dabang JMR R&R. Two layers:

1. **Project Context** — facts about the paper, data, design, and revision backlog. Updated as the project progresses.
2. **Generic `[LEARN:category]` entries** — corrections that should outlive this project. Append at bottom; most recent at the bottom.

Keep this file under ~200 lines so it stays fully visible in every session.

---

## Project Context

### Paper
- **Title:** From "Me" to "We": The Effect of a Gamified Community Leaderboard on User Content Generation
- **Journal:** Journal of Marketing Research
- **Manuscript ID:** JMR-25-0786
- **Decision:** R&R round 1, "very risky revision" (SE)
- **Paper source:** [overleaf-weibo-dabang/main.tex](overleaf-weibo-dabang/main.tex) (git submodule)
- **Bibliography:** [overleaf-weibo-dabang/references2.bib](overleaf-weibo-dabang/references2.bib)
- **Round-1 review letter:** [overleaf-weibo-dabang/response_letter_JMR_first_round.tex](overleaf-weibo-dabang/response_letter_JMR_first_round.tex) — canonical comment source

### Coauthor's Stata workflow (the replication target)
- [data/raw/data and code/analysis.do](data/raw/data and code/analysis.do) — user-day panel DiD
- [data/raw/data and code/analysis_tweet.do](data/raw/data and code/analysis_tweet.do) — post-/comment-level analysis
- [data/raw/stata data/](data/raw/stata data/) — `data_post.dta`, `data_comment.dta`
- Underlying CSVs (referenced from old `E:\Project-Weibo\dabang\stars_panel_data_and_extented_contents\新建文件夹\`): `pub_ex.csv` (posts), `comment_ex.csv` (comments), `wb_pub_ex.csv` (other Weibo posts).
- `data/raw/back of the envelope data/` holds intermediate one-off summaries (not part of the production pipeline).

### Empirical design facts (extracted from `analysis.do`)
- **Treatment date:** 2018-06-27 (`dabang_launch_date_1 = date("Jun 27 2018","MDY")`).
- **Treatment definition:** `treat_1 = 1` if `group == 1`, `treat_1 = 0` if `group == 3`. `group == 2` (commented out as treated in current Stata) is dropped.
- **Sample window:** roughly 2018-05-28 → 2018-07-22 in `analysis_tweet.do`; placebo dates set at May 27 and Apr 27 (1- and 2-month back).
- **Active-user filter:** Stata had `replace sample = 0 if total_post < 8` commented out; current spec keeps all sampled users with `sample == 1`.
- **Demographics constructed:** `male = (gender == 1)`; `age = 2018 - year(birthday)`.
- **Outcome variables in submitted paper:** number of original posts, number of comments, length of posts, length of comments, likes, duplicate flag.

### Cross-machine paths
- `data/raw -> /Volumes/dataHP/Dropbox/Project/Sina Dabang/data` (this Mac only). Other machines need an equivalent symlink or local Dropbox sync.
- `claude-code-my-workflow -> /Users/weimiao/data/github/claude-code-my-workflow` (this Mac only; upstream fork checkout for template updates).

### Reviewer-team summary (round 1)
- **SE:** 4 critical asks — motivation beyond gap-spotting; sharpened theory (one SIT dimension); transparent context; analyses beyond simple DiD.
- **AE:** 10 numbered points — Positioning (1–3), Theory (4–8), Data & Method (9a–i), Discussion (10a–d). Calls AE comments the "revision road map." Notable asks: PSM as primary (9c), longer pre-trends (9d), multivariate DiD/SUR (9e), drop one of FE/clustered SE (9f), spillover/leak controls (9g), point-allocation across communities (9h), strategic-selection of superstar communities (9i).
- **R1:** motivation/managerial framing weak; theory fragmented across multiple untested mechanisms; H6 U-shape ad hoc; Table 1 N inconsistent across rows, no winsorization noted; Length-units undefined; PSM should be main (Gordon et al. 2019); short pre-period; multivariate DiD; effect sizes interpreted without normalization.
- **R2:** situate within broader gamification literature (sales, training, education, etc.); SUTVA risk (treated and control coexist within a community → WOM leak); how zeros are handled in log; cluster SE by community; SUR for quantity↔quality; thresholds for community-size curve; dark side (Weibo's own removal). Heterogeneity ideas: creators vs members (R2-7), multi-community users (R2-8), loyalty changes (R2-9), niche communities (R2-10).
- **R3:** leaderboard mechanics under-described (visibility, points, contribution rules, what treated vs control saw); Table 1 N/definitions; superstar-community scope (categories, sizes); alt quality measures (Gunning-Fog, stop-word ratio) need justification; new DVs (R3-11: own-thread comments, breadth, eagerness); aggressiveness split by focal vs other community (R3-13); abstract logic question on quality preservation (R3-15).

### Methodological backlog (round-1 deliverables)
| # | Deliverable | Driving asks |
|---|---|---|
| 1 | Replicate submitted paper Tables 1–8 in R | self (replication-protocol) |
| 2 | Reviewer-comment tracker | all |
| 3 | Multivariate DiD / SUR for quantity ↔ quality | AE-9e, R1-9, R2-3d |
| 4 | PSM as primary matching strategy + longer pre-trends | AE-9c/d, R1-7/8 |
| 5 | Heterogeneity by default rank + community-size thresholds | AE-6, R2-2a/3e |
| 6 | Spillover / SUTVA / text-leak controls | AE-9g, R2-3a, R3-1 |
| 7 | New DVs (own-thread, breadth, eagerness) + alt quality justifications | R3-11/12 |
| 8 | Dark-side discussion + long-run / monetization implications | AE-10, R2-5/6 |
| 9 | Drop user-FE OR clustered-by-user SE (one, not both) | AE-9f |
| 10 | Strategic-selection statement on superstar communities | AE-9i |

---

## Generic `[LEARN]` entries (kept from upstream)

Most upstream entries are about template development (dogfooding, audit lessons, summary parity) and were dropped. The few below are useful for any working academic project.

[LEARN:workflow] Spec-then-plan for ambiguous tasks (>1 hr or >3 files): AskUserQuestion (3-5 questions) → write `quality_reports/specs/YYYY-MM-DD_description.md` with MUST/SHOULD/MAY priorities and CLEAR/ASSUMED/BLOCKED clarity status → get approval → only then plan. Catches ambiguity early; cuts rework 30–50%.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive auto-compression and session boundaries. Quality reports only at merge time.

[LEARN:workflow] Context survival before compression: (1) MEMORY.md updated with `[LEARN]` entries, (2) session log current (last 10 min), (3) active plan saved to disk, (4) open questions documented. The pre-compact hook surfaces this checklist.

[LEARN:hooks] `initialPermissionMode` only fires at session start; mid-session toggles (`Shift+Tab` or `/permission-mode`) override file settings until session end. The 6-tier permission stack: VSCode user / workspace / CLI user / project / project-local / in-session runtime — the last is authoritative. "Prompts fire despite bypass config" is almost always a stale session, not a settings bug.

[LEARN:hooks] Stop / PreCompact hooks support two block protocols: legacy `exit 2 + reason on stderr`, and modern `exit 0 + JSON {"decision":"block","reason":"..."} on stdout`. This template uses the modern form. Audit agents unfamiliar with this will mis-flag it as "should exit 2."

[LEARN:safety] Plan→Bypass is "review-before-execute convenience," not a "safety boundary." Exiting plan mode returns the session to `defaultMode` (bypassPermissions), so any tool call runs under the full allowlist. For real enforcement, keep `defaultMode: "default"` and approve high-risk tools individually.

[LEARN:scheduling] `CronCreate` is session-only in practice — dies when the Claude Code REPL isn't running. For autonomous work that must survive session termination (rate limits, restarts), use Claude Code Routines (web infra). `CronCreate` is fine for short in-session polling; not for "run this in an hour."

## Fork conventions (weim-mkt — inherited from the workflow fork)

[LEARN:feedback] `/commit` is local-only by default in this fork. Stop after `git commit`; do NOT push, open a PR, merge, or pull main unless the user explicitly asks in the same turn ("push", "open a PR", "merge", or `--push`/`--pr`/`--merge`).

**Why:** Explicit gating between local commit and any remote-affecting operation. A prior `/commit` does not authorize a later push.

**How to apply:** After `git commit`, report the hash and branch, then stop. When opening a PR on explicit request, default `gh pr create --repo <user>/<repo>` to the user's fork (gh defaults to the parent, which is usually wrong).

[LEARN:feedback] This project keeps R analysis under `code/` (not `scripts/R/`). Drift guard `.claude/hooks/check-code-path.sh` fires on `SessionStart` and on `git post-merge` (if `core.hooksPath=.githooks` is set) to flag any reintroduced `scripts/R/` references.

## Project-specific entries (append below as discovered)

<!-- New [LEARN] entries from this revision project go here, most recent at the bottom. -->
