# CLAUDE.md — Weibo Dabang JMR R&R

**Project:** From "Me" to "We": Effect of a Gamified Community Leaderboard on User Content Generation
**Journal:** Journal of Marketing Research (JMR-25-0786)
**Status:** R&R Round 1 (very risky revision per SE letter)
**Institution:** UCL School of Management
**Branch:** main

---

## Core Principles

- **Plan first** — enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`.
- **Verify after** — run scripts / render slides / compile reports and confirm output before declaring a task done.
- **Quality gates** — nothing ships below 80/100 (advisory; enforced by `/commit`).
- **`[LEARN]` tags** — when corrected, save `[LEARN:category] wrong → right` to `MEMORY.md`.
- **No em dashes** — do not use `—` in generated prose. See [`.claude/rules/writing-style.md`](.claude/rules/writing-style.md).
- **Replication before extension** — port and verify coauthor's Stata results in R *before* layering reviewer-driven changes. See [`.claude/rules/replication-protocol.md`](.claude/rules/replication-protocol.md).

Cross-session context lives in [MEMORY.md](MEMORY.md); past plans, specs, and session logs are in [quality_reports/](quality_reports/).

---

## Folder Structure

```
weibo-dabang/
├── CLAUDE.md                       # This file
├── MEMORY.md                       # Cross-session learnings + project facts
├── TEMPLATE_VERSION.md             # Workflow template version pin
├── .claude/                        # Rules, skills, agents, hooks, settings.json
├── .githooks/                      # Local git hooks (activate: git config core.hooksPath .githooks)
├── code/                           # R analysis pipeline (numbered scripts)
│   ├── scripts/                    # Standalone R/Python/Stata utilities
│   ├── utils/                      # Shared helpers (data IO, themes, clustering)
│   ├── diagnostics/                # Standalone diagnostic scripts
│   └── _outputs/                   # Generated artifacts (gitignored)
├── data/
│   ├── raw -> Dropbox              # Coauthor's Stata data + scripts (READ-ONLY)
│   └── processed/                  # Cleaned/derived datasets (gitignored)
├── overleaf-weibo-dabang/          # SUBMODULE: paper + initial response letter
├── Quarto/                         # Slides for internal updates / conference talks
├── Figures/                        # Publication-ready figures (gitignored outputs go to code/_outputs/)
├── quality_reports/                # Plans, specs, session logs, decision records, merge reports
├── explorations/                   # Sandbox for experimental analyses (see exploration rules)
├── scripts/                        # Project-level utilities (quality_score.py, etc.)
├── templates/                      # Session log, response-to-referees, requirements-spec templates
└── claude-code-my-workflow/        # Symlink to upstream fork (for pulling template updates only)
```

---

## Languages & Tools

- **R is primary** for the revision pipeline. Build on coauthor's Stata workflow:
  - [data/raw/data and code/analysis.do](data/raw/data and code/analysis.do) — user-day panel DiD
  - [data/raw/data and code/analysis_tweet.do](data/raw/data and code/analysis_tweet.do) — post/comment-level analysis
  - [data/raw/stata data/](data/raw/stata data/) — `data_post.dta`, `data_comment.dta`
- **Python** for ad hoc text/NLP work (sentiment, duplicate detection, leaderboard-mention classifier).
- **Stata** kept on hand for parity checks during R port; not the production runtime.
- **Quarto** for internal/conference slides (no Beamer in this project).

---

## Submodule Policy: `overleaf-weibo-dabang/`

The Overleaf paper is a **separate git repo** mounted as a submodule. Treat it as such:

- Read freely (paper text, response letter, references, figures).
- **Edit deliberately**, then `cd overleaf-weibo-dabang && git add ... && git commit && git push` from inside the submodule. Never `git add overleaf-weibo-dabang/...` from the parent repo unless intentionally bumping the submodule pointer.
- The response letter for round 1 lives at [overleaf-weibo-dabang/response_letter_JMR_first_round.tex](overleaf-weibo-dabang/response_letter_JMR_first_round.tex). New responses go in the same file.
- Bibliography lives at [overleaf-weibo-dabang/references2.bib](overleaf-weibo-dabang/references2.bib); do not maintain a parallel project-root bib.

---

## Data Policy

- `data/raw/` is a Dropbox-backed symlink and is treated as **read-only**. Never write outputs there.
- Cleaned/derived datasets land in `data/processed/` (gitignored).
- Analysis artifacts (tables, figures, model objects) land in `code/_outputs/` (gitignored).
- Set `here::i_am("CLAUDE.md")` at project root in every R script so paths resolve correctly across machines.

---

## Commands

```bash
# Run an R analysis script (always from project root)
Rscript code/<filename>.R

# Quality score a changed file
python3 scripts/quality_score.py code/<file>.R   # or Quarto/<file>.qmd

# Drift guards (also wired into /commit)
bash scripts/check-surface-sync.sh
python3 scripts/check-skill-integrity.py

# Render a Quarto slide deck and sync to docs/
bash scripts/sync_to_docs.sh <DeckName>

# Activate the local post-merge drift guard (one-time, per clone)
git config core.hooksPath .githooks

# Submodule operations
git submodule status
cd overleaf-weibo-dabang && git status
```

---

## Quality Thresholds (advisory)

| Score | Checkpoint | Meaning |
|---|---|---|
| 80 | Commit | Good enough to save to local git |
| 90 | Push / submit-ready | Ready for coauthor sharing or Overleaf push |
| 95 | Excellence | Aspirational, submission-grade polish |

Enforced by `/commit` (halts and asks for override on failure); not enforced by a git pre-commit hook.

---

## Skills Quick Reference (this project)

| Command | What It Does |
|---|---|
| `/data-analysis [dataset]` | End-to-end R analysis pipeline scaffold |
| `/review-r [file]` | R code quality review |
| `/audit-reproducibility [paper]` | Cross-check paper claims against `code/_outputs/` |
| `/review-paper [file]` | Manuscript review (`--adversarial` / `--peer <journal>`) |
| `/respond-to-referees [report] [manuscript]` | R&R response-letter generator (drafts merge into Overleaf .tex) |
| `/seven-pass-review` | Forked parallel adversarial manuscript review |
| `/lit-review [topic]` | Literature search + synthesis (Post-Flight verified) |
| `/research-ideation [topic]` | Brainstorm research extensions / robustness checks |
| `/interview-me [topic]` | Interactive scoping interview |
| `/devils-advocate` | Adversarial challenge on a design decision |
| `/verify-claims [file]` | Chain-of-Verification fact-check on a draft block |
| `/proofread [file]` | Sentence-level grammar/typo/cohesion proposal |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/commit [msg]` | Stage, run quality gates, commit (local-only by default) |
| `/learn [skill-name]` | Promote a discovery into a persistent skill or MEMORY entry |
| `/context-status` | Show session health and context usage |
| `/deep-audit` | Repository-wide consistency audit (template-maintenance) |
| `/permission-check` | Diagnose permission layers when prompts fire unexpectedly |

Removed (Beamer / teaching only): `/compile-latex`, `/create-lecture`, `/translate-to-quarto`, `/qa-quarto`, `/extract-tikz`, `/new-diagram`, `/pedagogy-review`, `/slide-excellence`, `/visual-audit`.

---

## Reviewer-Team Map (Round 1)

Canonical comment source: [overleaf-weibo-dabang/response_letter_JMR_first_round.tex](overleaf-weibo-dabang/response_letter_JMR_first_round.tex).

- **SE** — endorses 4 critical asks: stronger motivation, sharpened theory, transparent context, more comprehensive analyses beyond simple DiD.
- **AE** — 10 numbered points spanning Positioning (1–3), Theory (4–8), Data & Method (9a–i), Discussion (10a–d). Closely overlaps R1.
- **R1** — gap-only motivation insufficient; theory framework fragmented (multiple mechanisms, none tested); Table 1 N/units inconsistent; PSM should be primary (not CEM as robustness); short pre-period; multivariate DiD needed; effect sizes interpreted without normalization.
- **R2** — situate in broader gamification literature; SUTVA risk (treated and control coexist within a community); how are zeros handled in log transforms; cluster SE by community; SUR for quantity↔quality; thresholds for community-size curve; dark side of leaderboards (Weibo's own removal as cautionary).
- **R3** — leaderboard mechanics under-described (visibility, points, contribution rules); Table 1 N/definitions; superstar-community scope and generalizability; alternative quality measures need justification; new DVs (own-thread comments, breadth, eagerness).

---

## Quarto CSS Classes (placeholder, populate when slide theme exists)

| Class | Effect | Use Case |
|---|---|---|
| *(none yet)* | | |

---

## Current Project State — Workstreams

| # | Workstream | Driving asks | Status |
|---|---|---|---|
| 1 | R-port replication of submitted results | Self (replication-protocol) | Not started |
| 2 | Reviewer-comment tracker (one row per comment → deliverable) | All | Not started |
| 3 | Motivation rewrite (community vs individual gamification) | AE-1, R1-1 | Not started |
| 4 | Theory consolidation (single SIT dimension + testable mechanism) | AE-4, AE-7, R1-3 | Not started |
| 5 | Context/leaderboard transparency (visibility, points, rules) | AE-3, R3-2/5/7 | Not started |
| 6 | Multivariate DiD / SUR for quantity ↔ quality | AE-9e, R1-9, R2-3d | Not started |
| 7 | PSM as main matching strategy + longer pre-trends | AE-9c/d, R1-7/8 | Not started |
| 8 | Heterogeneity by default rank + community size thresholds | AE-6, R2-2a/3e | Not started |
| 9 | Spillover / SUTVA / text-leak controls | AE-9g, R2-3a, R3-1 | Not started |
| 10 | New DVs + alternative quality measures with rationale | R3-11/12 | Not started |
| 11 | Dark-side discussion + long-run / monetization implications | AE-10, R2-5/6 | Not started |
| 12 | Response letter draft (in Overleaf submodule) | All | Not started |
