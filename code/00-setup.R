# 00-setup.R ----
# Defines setup_env(): loads packages, sets options, returns a paths list.
# Sourced by main.R; defines functions only, no top-level side effects beyond
# `here::i_am()` (the project anchor must run on source).

here::i_am("CLAUDE.md")

#' Initialize the analysis environment.
#'
#' Loads required packages, sets reproducibility defaults, builds the paths
#' list, and creates output directories on disk.
#'
#' @return A named list with keys `raw`, `processed`, `outputs`, `tables`,
#'   `models` (all absolute paths) and `const` (experiment constants).
setup_env <- function() {
  suppressPackageStartupMessages({
    library(here)
    library(data.table)
    library(haven)
    library(fst)
    library(qs2)
    library(fixest)
    library(MatchIt)
    library(modelsummary)
    library(ggplot2)
    library(ggthemes)
    library(lubridate)
  })

  set.seed(888)
  data.table::setDTthreads(0L)
  options(
    datatable.print.nrows = 50L,
    datatable.print.class = TRUE,
    fixest_etable_arraystretch = 1.1
  )
  fixest::setFixest_etable(markdown = FALSE)
  ggplot2::theme_set(ggthemes::theme_stata())

  paths <- list(
    raw       = here("data", "raw", "data and code"),
    processed = here("data", "processed"),
    outputs   = here("code", "_outputs"),
    tables    = here("code", "_outputs", "tables"),
    models    = here("code", "_outputs", "models"),
    const = list(
      treatment_date = as.Date("2018-06-27"),
      sample_start   = as.Date("2018-05-28"),
      sample_end     = as.Date("2018-07-22"),
      cluster_var    = "uid"
    )
  )

  for (p in c(paths$processed, paths$tables, paths$models)) {
    dir.create(p, recursive = TRUE, showWarnings = FALSE)
  }

  paths
}
