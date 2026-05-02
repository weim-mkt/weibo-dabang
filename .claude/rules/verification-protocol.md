---
paths:
  - "Quarto/**/*.qmd"
  - "code/**/*.R"
  - "docs/**"
  - "overleaf-weibo-dabang/**/*.tex"
---

# Task Completion Verification Protocol

**At the end of EVERY task, verify the output works correctly.** This is non-negotiable.

## For R Scripts:
1. Run `Rscript code/<filename>.R` from the project root.
2. Verify output files in `code/_outputs/` (RDS, fst, qs2, CSV, PDF, PNG) were created and have non-zero size.
3. Spot-check estimates for reasonable magnitude and sign:
   - DiD coefficients on comment volume should be positive per the submitted paper.
   - Comment-quality DiD coefficients should be negative (small magnitude).
   - Original-post quality coefficients should be near zero and statistically insignificant.
4. If the script writes a tidy results table, `read_csv("code/_outputs/<file>.csv")` and confirm column names match the analysis brief.
5. Append a one-line entry to the active session log noting "ran `code/<file>.R`, outputs: ..."

## For Quarto/HTML Slides:
1. Run `bash scripts/sync_to_docs.sh <DeckName>` to render and copy artifacts to `docs/`.
2. Open the HTML in browser: `open docs/slides/<DeckName>.html` (macOS).
3. Verify images display by reading 2-3 image files to confirm non-empty content.
4. Check the HTML source for correct image paths.
5. Scan dense slides for overflow.

## For Manuscript edits in `overleaf-weibo-dabang/`:
1. Treat the submodule as a separate repo: edits inside it must be committed and pushed from inside the submodule (`cd overleaf-weibo-dabang && git ...`).
2. Do not compile xelatex locally; Overleaf does that. Instead, verify:
   - All cited keys appear in `references2.bib` (`grep -F '\cite' main.tex` then check keys exist in the bib).
   - Numeric claims that came from `code/_outputs/` still match (run `/audit-reproducibility` on the changed sections).
   - No em dashes appeared in newly written prose.
3. After pushing the submodule, bump the parent-repo submodule pointer with an explicit `git add overleaf-weibo-dabang && git commit -m "bump overleaf submodule"` -- never silent.

## For TikZ / SVG figures (rare; only if a Quarto deck embeds vector diagrams):
1. Browsers cannot display PDF images inline -- convert to SVG via `pdf2svg`.
2. Verify SVG files contain valid XML/SVG markup.
3. Copy SVGs to `docs/Figures/<deck>/` via `sync_to_docs.sh`.

## Common Pitfalls:
- **Symlink leakage**: don't write to `data/raw/` -- it is the read-only Dropbox mount.
- **Hardcoded absolute paths**: always use `here::here(...)` so collaborators can re-run without editing paths.
- **Missing `set.seed(888)`**: any randomness (matching, bootstrap, causal forest) must be seeded; assert seed presence before any sampling call.
- **Assuming success**: always confirm output files exist AND contain plausible values; do not infer success from a clean exit code alone.
- **Submodule drift**: `git status` from the parent repo will *not* show changes inside `overleaf-weibo-dabang/`; use `git submodule status` and `git -C overleaf-weibo-dabang status` together.

## Verification Checklist:
```
[ ] Output file(s) created with non-zero size
[ ] No render / runtime errors
[ ] Numeric values pass tolerance check vs. expected (replication-protocol.md)
[ ] Paths resolve via here::here() and reproduce on a clean R session
[ ] Submodule state intact and intentional (if Overleaf was touched)
[ ] Reported results to user (one-line summary, key numbers, file paths)
```
