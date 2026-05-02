# main.R ----
# JMR R&R replication entry point.
# Sources function definitions from numbered scripts, then orchestrates each
# analysis explicitly so the full pipeline is visible at a glance.

source(here::here("code", "00-setup.R"))
source(here::here("code", "01-clean_data.R"))
source(here::here("code", "02-analysis.R"))

# Environment + cached datasets ----
paths <- setup_env()
build_caches(paths)

# Analyses (one call per submitted-paper table) ----
run_summary_stats(paths)            # Table 1: descriptives
run_pretreatment_balance(paths)     # Table 2: treat vs control t-tests
run_did_content_quantity(paths)     # Table 3: main DiD on posts/comments/content
run_did_content_quality(paths)      # Table 4: length, likes, duplicates
run_event_study(paths)              # Table 5: relative-time parallel-trends
run_cem_matched_did(paths)          # Table 6: CEM-matched robustness
run_did_point_contribution(paths)   # Table 7: voting frequency / points
run_iv_late(paths)                  # Table 8: LATE / IV on consume_ind

cat("[main] pipeline complete; tables in ", paths$tables, "\n")
