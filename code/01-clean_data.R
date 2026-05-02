# 01-clean_data.R ----
# Defines functions that read each coauthor .dta exactly once, cache as .fst,
# and apply minimal post-load derivations needed by 02-analysis.R. Analysis
# functions later read the .fst caches directly via load_user_day(), etc.

#' Load a .dta into memory once, then cache to .fst forever.
load_or_cache <- function(dta_path, fst_path) {
  if (file.exists(fst_path)) {
    message("[01] cache hit: ", basename(fst_path))
    return(fst::read_fst(fst_path, as.data.table = TRUE))
  }
  if (!file.exists(dta_path)) {
    stop("Source .dta not found: ", dta_path)
  }
  message("[01] reading .dta (slow): ", basename(dta_path))
  dt <- haven::read_dta(dta_path) |> data.table::as.data.table()
  dir.create(dirname(fst_path), recursive = TRUE, showWarnings = FALSE)
  fst::write_fst(dt, fst_path, compress = 75L)
  message("[01] cached to: ", basename(fst_path),
          " (", format(nrow(dt), big.mark = ","), " rows)")
  dt
}

#' Idempotent column derivation (only adds if absent).
ensure_col <- function(dt, name, expr_quote) {
  if (!name %in% names(dt)) {
    dt[, (name) := eval(expr_quote, envir = dt)]
  }
  invisible(dt)
}

#' Coerce a column to Date if it isn't already (handles Stata-day numeric).
coerce_date <- function(dt, col = "date") {
  if (!inherits(dt[[col]], "Date")) {
    if (is.numeric(dt[[col]])) {
      dt[, (col) := as.Date(get(col), origin = "1960-01-01")]
    } else {
      dt[, (col) := as.Date(get(col))]
    }
  }
  invisible(dt)
}

#' Build the user-day panel cache (Tables 1, 2, 3, 5, 6, 7, 8).
build_user_day <- function(paths) {
  fst_path <- file.path(paths$processed, "user_day_panel.fst")
  user_day <- load_or_cache(
    file.path(paths$raw, "main_data_new.dta"),
    fst_path
  )
  coerce_date(user_day)

  ensure_col(user_day, "treat_1",
             quote(fifelse(group == 1, 1L,
                           fifelse(group == 3, 0L, NA_integer_))))
  ensure_col(user_day, "after_1",
             quote(as.integer(date >= paths$const$treatment_date)))

  if ("sample" %in% names(user_day)) user_day <- user_day[sample == 1]
  user_day <- user_day[!is.na(treat_1)]

  log_targets <- c("post_original_num_in", "post_transmit_num_in",
                   "comment_num_in", "liked_num_in",
                   "consume_times", "consume_value")
  for (v in log_targets) {
    out <- paste0("log_", v)
    if (v %in% names(user_day) && !out %in% names(user_day)) {
      user_day[, (out) := log1p(get(v))]
    }
  }

  if (all(c("post_original_num_in", "post_transmit_num_in", "comment_num_in") %in% names(user_day)) &&
      !"content_num_in" %in% names(user_day)) {
    user_day[, content_num_in := post_original_num_in +
               post_transmit_num_in + comment_num_in]
    user_day[, log_content_num_in := log1p(content_num_in)]
  }

  for (v in c("post_original_num_in", "comment_num_in", "post_transmit_num_in")) {
    ind_name <- paste0("ind_", v)
    if (v %in% names(user_day) && !ind_name %in% names(user_day)) {
      user_day[, (ind_name) := as.integer(get(v) > 0)]
    }
  }

  if (!"date_gap" %in% names(user_day)) {
    user_day[, date_gap := as.integer(date - paths$const$treatment_date)]
  }
  user_day[, `:=`(
    pre_week_4  = as.integer(date_gap >= -28 & date_gap <= -22),
    pre_week_3  = as.integer(date_gap >= -21 & date_gap <= -15),
    pre_week_2  = as.integer(date_gap >= -14 & date_gap <=  -8),
    pre_week_1  = as.integer(date_gap >=  -7 & date_gap <=  -1),
    post_week_1 = as.integer(date_gap >=   0 & date_gap <=   6),
    post_week_2 = as.integer(date_gap >=   7 & date_gap <=  13),
    post_week_3 = as.integer(date_gap >=  14 & date_gap <=  20),
    post_week_4 = as.integer(date_gap >=  21 & date_gap <=  27)
  )]

  if (!"consume_ind" %in% names(user_day)) {
    if ("consume_freq" %in% names(user_day)) {
      user_day[, consume_ind := as.integer(consume_freq > 0)]
    } else if ("consume_times" %in% names(user_day)) {
      user_day[, consume_ind := as.integer(!is.na(consume_times) &
                                             consume_times > 0)]
    }
  }
  if ("consume_ind" %in% names(user_day)) {
    user_day[, int_consume_ind_after_1 := consume_ind * after_1]
    user_day[, int_treat_1_after_1     := treat_1 * after_1]
  }

  fst::write_fst(user_day, fst_path, compress = 75L)

  cat(sprintf("[01] user_day_panel: %s rows, %s users\n",
              format(nrow(user_day), big.mark = ","),
              format(uniqueN(user_day$uid), big.mark = ",")))
  cat("[01] treat x after cell sizes:\n")
  print(user_day[, .N, keyby = .(treat_1, after_1)])

  invisible(fst_path)
}

#' Build the post-quality cache (Table 4 panel B).
build_post_quality <- function(paths) {
  fst_path <- file.path(paths$processed, "post_quality.fst")
  dt <- load_or_cache(
    file.path(paths$raw, "main_data_post.dta"),
    fst_path
  )
  coerce_date(dt)
  ensure_col(dt, "treat_1",
             quote(fifelse(group == 1, 1L,
                           fifelse(group == 3, 0L, NA_integer_))))
  ensure_col(dt, "after_1",
             quote(as.integer(date >= paths$const$treatment_date)))
  if ("sample" %in% names(dt)) dt <- dt[sample == 1]
  dt <- dt[!is.na(treat_1)]
  fst::write_fst(dt, fst_path, compress = 75L)
  cat(sprintf("[01] post_quality:    %s rows\n",
              format(nrow(dt), big.mark = ",")))
  invisible(fst_path)
}

#' Build the comment-quality cache (Table 4 panels A & C).
build_comment_quality <- function(paths) {
  fst_path <- file.path(paths$processed, "comment_quality.fst")
  dt <- load_or_cache(
    file.path(paths$raw, "main_data_tweet.dta"),
    fst_path
  )
  coerce_date(dt)
  ensure_col(dt, "treat_1",
             quote(fifelse(group == 1, 1L,
                           fifelse(group == 3, 0L, NA_integer_))))
  ensure_col(dt, "after_1",
             quote(as.integer(date >= paths$const$treatment_date)))
  if ("sample" %in% names(dt)) dt <- dt[sample == 1]
  dt <- dt[!is.na(treat_1)]
  fst::write_fst(dt, fst_path, compress = 75L)
  cat(sprintf("[01] comment_quality: %s rows\n",
              format(nrow(dt), big.mark = ",")))
  invisible(fst_path)
}

#' Top-level: build all three caches.
build_caches <- function(paths) {
  build_user_day(paths)
  build_post_quality(paths)
  build_comment_quality(paths)
  invisible(NULL)
}

#' On-demand readers used by 02-analysis.R.
load_user_day <- function(paths) {
  fst::read_fst(file.path(paths$processed, "user_day_panel.fst"),
                as.data.table = TRUE)
}
load_post_quality <- function(paths) {
  fst::read_fst(file.path(paths$processed, "post_quality.fst"),
                as.data.table = TRUE)
}
load_comment_quality <- function(paths) {
  fst::read_fst(file.path(paths$processed, "comment_quality.fst"),
                as.data.table = TRUE)
}
