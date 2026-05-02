---
paths:
  - "Quarto/**/*.qmd"
  - "Quarto/**/*.scss"
  - "code/**/*.R"
  - "overleaf-weibo-dabang/**/*.tex"
---

# Content Invariants

Numbered non-negotiable rules for content produced in this repository. Critic agents, reviewers, and audit agents should cite invariants by number (e.g., "violates INV-3") when flagging issues. Adapted from clo-author's enforcement pattern; trimmed for an R-and-paper project (Beamer-only INV removed).

## Slide / paper invariants

- **INV-1: Palette sync.** *Deferred until a Quarto theme is established.* When a slide deck adopts a custom palette, color names used in the deck and any project-wide SCSS file must agree; add a check to `scripts/check-surface-sync.sh` before merging the new theme.
- **INV-2: Notation parity (paper / slides / code).** Every math symbol, variable name, and subscript that appears in [overleaf-weibo-dabang/main.tex](overleaf-weibo-dabang/main.tex) must match the registry in [`.claude/rules/knowledge-base.md`](knowledge-base.md). Code-side variable names (e.g., `n_comments`, `treat`, `post`) follow the variable-reference table in the same knowledge base. Notation drift between paper / slides / code is a critical bug.
- **INV-3: Quarto CSS override contract.** Styles that must override Bootstrap defaults (inline code color, code block background, table borders) go in `include-in-header` as a raw `<style>` tag, never in the SCSS file. SCSS is only for styles that do not need to beat Bootstrap's cascade.
- **INV-4: Vector figures only in Quarto.** Browsers cannot render PDF images inline. Quarto/HTML decks must embed SVG (preferred) or high-DPI PNG. No raw `.pdf` images in `.qmd`.
- **INV-5: Single bibliography.** [overleaf-weibo-dabang/references2.bib](../../overleaf-weibo-dabang/references2.bib) is the canonical bibliography. Do not maintain a parallel project-root bib. Slide decks that need citations should reference the same `.bib` (relative path) so cite keys do not drift.

## Slide design invariants

- **INV-7: Max 2 colored boxes per slide.** Overusing callout environments creates "box fatigue." Two per slide maximum.
- **INV-8: Motivation before formalism.** Every definition or model statement must be preceded by a motivating example, intuition, or research question. No unmotivated math.

## R script invariants

- **INV-9: `set.seed(888)` before every randomness step.** Every R script that uses randomness must call `set.seed(888)` immediately before each stochastic step (matching, bootstrap, train/test split, causal-forest fit). Not once at the top of the script. The per-step convention keeps each randomness block independently reproducible when re-run in isolation. Never inside loops or inside functions called in loops; seed before the loop. For parallel work, also set `RNGkind("L'Ecuyer-CMRG")`. See [`.claude/rules/r-code-conventions.md`](r-code-conventions.md).
- **INV-10: Relative paths only.** No absolute paths (`/Users/...`, `/Volumes/...`, `C:\...`, `~` expansion). All paths relative to the repository root, resolved via `here::here()`. The Dropbox-backed `data/raw/` symlink is the one tolerated absolute target.
- **INV-11: Publication-ready figures.** All `ggsave()` calls produce figures with explicit `width`, `height`, `units = "in"`, `dpi = 300`. Default `device = "cairo_pdf"` for vector output destined for the paper; `"png"` for slide thumbnails.
- **INV-12: Project theme on all plots.** Every ggplot figure must use the project's custom theme (defined in `code/utils/themes.R` once authored). No default ggplot2 gray backgrounds in any committed figure.

## Manuscript invariants (round-1 specific)

- **INV-13: Reviewer-comment cross-reference.** Every change in [overleaf-weibo-dabang/main.tex](../../overleaf-weibo-dabang/main.tex) introduced during this revision round must be cross-referenced from a corresponding response in [overleaf-weibo-dabang/response_letter_JMR_first_round.tex](../../overleaf-weibo-dabang/response_letter_JMR_first_round.tex). The reviewer-comment tracker in `quality_reports/plans/` is the index. No silent edits.
- **INV-14: Numeric claims trace to `code/_outputs/`.** Any number reported in the manuscript that came from analysis must be reproducible from a script in `code/`. `/audit-reproducibility` is the gate.
