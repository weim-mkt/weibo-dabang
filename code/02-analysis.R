# 02-analysis.R ----
# Per-table analysis functions. Each `run_tableNN_*(paths)` reads the relevant
# .fst cache, fits models, writes a long-format CSV (and a .qs2 of the model
# objects), and returns the result data.table invisibly.
#
# Stata source-of-truth:
#   data/raw/data and code/analysis.do        (user-day DiD; Tables 1, 2, 3, 5, 6, 7, 8)
#   data/raw/data and code/analysis_tweet.do  (post/comment quality; Table 4)

# ---- Shared helpers ---------------------------------------------------------

#' Build a fixest formula with FE pipe-notation.
make_did_formula <- function(dv, rhs = "treat_1 * after_1", fe = "uid + date") {
  stats::as.formula(sprintf("%s ~ %s | %s", dv, rhs, fe))
}

#' Tidy a fixest fit into long-format rows (one row per coefficient).
tidy_did <- function(fit, table, panel = "", column, model = NULL) {
  est <- as.data.table(fixest::coeftable(fit), keep.rownames = "term")
  setnames(est,
           c("Estimate", "Std. Error", "t value", "Pr(>|t|)"),
           c("estimate", "std_error", "t_stat", "p_value"))
  fe_sizes <- tryCatch(fit$fixef_sizes, error = function(e) NULL)
  est[, `:=`(
    table = table,
    panel = panel,
    column = column,
    n_obs = nobs(fit),
    fe = if (length(fe_sizes)) paste(names(fe_sizes), collapse = "+") else "",
    cluster = "uid"
  )]
  if (!is.null(model)) est[, model := model]
  setcolorder(est, c("table", "panel", "column", "term"))
  est[]
}

write_table <- function(rows, filename, paths) {
  fwrite(rows, file.path(paths$tables, filename))
  invisible(rows)
}

stata_summary <- function(dt, vars) {
  out <- lapply(vars, function(v) {
    x <- dt[[v]]
    data.table(
      variable = v,
      n        = sum(!is.na(x)),
      mean     = mean(x, na.rm = TRUE),
      sd       = sd(x,   na.rm = TRUE),
      min      = suppressWarnings(min(x, na.rm = TRUE)),
      max      = suppressWarnings(max(x, na.rm = TRUE))
    )
  })
  rbindlist(out)
}

# ---- Summary statistics (Table 1) -------------------------------------------
# analysis.do lines 456-489.
run_summary_stats <- function(paths) {
  user_day <- load_user_day(paths)

  main_vars <- intersect(
    c("treat_1", "after_1", "comment_num_in",
      "post_original_num_in", "post_transmit_num_in"),
    names(user_day)
  )
  main_panel <- stata_summary(user_day, main_vars)[, panel := "A_user_day"]

  vote_vars <- intersect(c("consume_times", "consume_value"), names(user_day))
  vote_panel <- if (length(vote_vars)) {
    stata_summary(user_day[treat_1 == 1 & after_1 == 1], vote_vars)[
      , panel := "B_voting_treated_post"]
  } else data.table()

  demo_vars <- intersect(
    c("male", "age", "tenure", "fans_num", "focus_num",
      "yellow_vip", "blue_vip", "expert_vip", "golden_vip"),
    names(user_day)
  )
  demo_panel <- if (length(demo_vars)) {
    stata_summary(unique(user_day, by = "uid"), demo_vars)[
      , panel := "C_demographics_user_level"]
  } else data.table()

  out <- rbindlist(list(main_panel, vote_panel, demo_panel),
                   use.names = TRUE, fill = TRUE)[, table := "table01"]
  write_table(out, "table01_summary_stats.csv", paths)
  invisible(out)
}

# ---- Pre-treatment group balance (Table 2) ----------------------------------
# analysis.do lines 380-392.
run_pretreatment_balance <- function(paths) {
  user_day <- load_user_day(paths)
  vars <- intersect(
    c("ave_post_original_num_in", "ave_comment_num_in",
      "male", "age", "tenure", "fans_num", "focus_num",
      "yellow_vip", "blue_vip", "expert_vip", "golden_vip"),
    names(user_day)
  )
  user_level <- unique(user_day, by = "uid")
  rows <- lapply(vars, function(v) {
    tt <- t.test(user_level[treat_1 == 1, get(v)],
                 user_level[treat_1 == 0, get(v)])
    data.table(
      table = "table02", panel = "balance", column = v,
      mean_treat   = unname(tt$estimate[1]),
      mean_control = unname(tt$estimate[2]),
      diff         = unname(tt$estimate[1] - tt$estimate[2]),
      t_stat       = unname(tt$statistic),
      p_value      = unname(tt$p.value),
      n_treat   = sum(!is.na(user_level[treat_1 == 1, get(v)])),
      n_control = sum(!is.na(user_level[treat_1 == 0, get(v)]))
    )
  })
  out <- rbindlist(rows)
  write_table(out, "table02_balance.csv", paths)
  invisible(out)
}

# ---- Main DiD on content quantity (Table 3) ---------------------------------
# analysis.do lines 670-712.
run_did_content_quantity <- function(paths) {
  user_day <- load_user_day(paths)
  specs <- list(
    log_post_original = "log_post_original_num_in",
    log_post_transmit = "log_post_transmit_num_in",
    log_comment       = "log_comment_num_in",
    log_content       = "log_content_num_in"
  )
  specs <- specs[vapply(specs, function(v) v %in% names(user_day), logical(1))]
  fits <- lapply(specs, function(dv)
    feols(make_did_formula(dv), data = user_day, cluster = ~uid))
  qs2::qs_save(fits, file.path(paths$models, "table03_quantity.qs2"))

  out <- rbindlist(lapply(names(fits), function(nm)
    tidy_did(fits[[nm]], "table03", "quantity", nm)))
  write_table(out, "table03_quantity.csv", paths)

  fixest::etable(fits,
                 file = file.path(paths$tables, "table03_quantity.tex"),
                 title = "Main DiD: Content Quantity",
                 label = "tab:main_quantity",
                 style.tex = style.tex("aer"),
                 digits = 3, tex = TRUE, replace = TRUE)
  invisible(out)
}

# ---- DiD on content quality (Table 4: overall, posts, comments) -------------
# analysis_tweet.do lines 651-666 (posts), 1115-1130 (comments / overall).
fit_quality_panel <- function(dt, panel_label, like_var, paths) {
  specs <- list(
    length    = "log_origin_len_daily",
    likes     = like_var,
    duplicate = "log_copy_daily"
  )
  specs <- specs[vapply(specs, function(v) v %in% names(dt), logical(1))]
  if (!length(specs)) {
    warning("[Table 4 / ", panel_label, "] no DVs found; skipping")
    return(data.table())
  }
  fits <- lapply(specs, function(dv)
    feols(make_did_formula(dv), data = dt, cluster = ~uid))
  qs2::qs_save(fits, file.path(paths$models,
                               sprintf("table04_%s.qs2", panel_label)))
  rbindlist(lapply(names(fits), function(nm)
    tidy_did(fits[[nm]], "table04", panel_label, nm)))
}

run_did_content_quality <- function(paths) {
  post_quality    <- load_post_quality(paths)
  comment_quality <- load_comment_quality(paths)

  panel_post    <- fit_quality_panel(post_quality,    "B_post",
                                     "log_post_liked_num_daily", paths)
  panel_comment <- fit_quality_panel(comment_quality, "C_comment",
                                     "log_comment_liked_num_daily", paths)
  panel_all     <- fit_quality_panel(comment_quality, "A_all",
                                     "log_comment_liked_num_daily", paths)

  out <- rbindlist(list(panel_all, panel_post, panel_comment),
                   use.names = TRUE, fill = TRUE)
  write_table(out, "table04_quality.csv", paths)
  invisible(out)
}

# ---- Event study / parallel trends (Table 5) --------------------------------
# analysis.do lines 2995-3043. pre_week_4 dropped as baseline.
run_event_study <- function(paths) {
  user_day <- load_user_day(paths)
  es_terms <- c("pre_week_3", "pre_week_2", "pre_week_1",
                "post_week_1", "post_week_2", "post_week_3", "post_week_4")
  es_rhs <- paste(sprintf("treat_1 * %s", es_terms), collapse = " + ")
  specs <- intersect(
    c("log_post_original_num_in", "log_comment_num_in", "log_content_num_in"),
    names(user_day)
  )
  fits <- setNames(lapply(specs, function(dv)
    feols(make_did_formula(dv, rhs = es_rhs),
          data = user_day, cluster = ~uid)), specs)
  qs2::qs_save(fits, file.path(paths$models, "table05_event_study.qs2"))

  out <- rbindlist(lapply(names(fits), function(nm)
    tidy_did(fits[[nm]], "table05", "event_study", nm)))
  write_table(out, "table05_event_study.csv", paths)

  fixest::etable(fits,
                 file = file.path(paths$tables, "table05_event_study.tex"),
                 title = "Event Study", label = "tab:event_study",
                 style.tex = style.tex("aer"),
                 digits = 3, tex = TRUE, replace = TRUE)
  invisible(out)
}

# ---- CEM-matched DiD robustness (Table 6) -----------------------------------
# analysis.do lines 814-865.
run_cem_matched_did <- function(paths) {
  user_day <- load_user_day(paths)
  match_vars <- intersect(
    c("male", "age", "tenure", "fans_num", "focus_num",
      "yellow_vip", "blue_vip", "expert_vip", "golden_vip",
      "ave_post_original_num_in", "ave_comment_num_in", "ave_signin_num"),
    names(user_day)
  )
  if (length(match_vars) < 4L || !requireNamespace("MatchIt", quietly = TRUE)) {
    warning("[Table 6] CEM matching skipped: needed columns missing.")
    out <- data.table()
    write_table(out, "table06_cem.csv", paths)
    return(invisible(out))
  }

  user_level_match <- stats::na.omit(unique(user_day, by = "uid")[
    , .SD, .SDcols = c("uid", "treat_1", match_vars)])
  set.seed(888)  # INV-9: stochastic tie-breaking in CEM
  cem_fit <- MatchIt::matchit(
    formula = reformulate(match_vars, "treat_1"),
    data    = user_level_match,
    method  = "cem"
  )
  matched_users <- MatchIt::match.data(cem_fit)$uid
  cem_panel <- user_day[uid %in% matched_users]
  cat(sprintf("[Table 6] CEM-matched users: %s of %s (%s rows in panel)\n",
              format(length(matched_users), big.mark = ","),
              format(uniqueN(user_day$uid), big.mark = ","),
              format(nrow(cem_panel), big.mark = ",")))

  specs <- list(
    log_post_original = "log_post_original_num_in",
    log_post_transmit = "log_post_transmit_num_in",
    log_comment       = "log_comment_num_in",
    log_content       = "log_content_num_in"
  )
  specs <- specs[vapply(specs, function(v) v %in% names(cem_panel), logical(1))]
  fits <- lapply(specs, function(dv)
    feols(make_did_formula(dv), data = cem_panel, cluster = ~uid))
  qs2::qs_save(fits, file.path(paths$models, "table06_cem.qs2"))

  out <- rbindlist(lapply(names(fits), function(nm)
    tidy_did(fits[[nm]], "table06", "cem_matched", nm)))
  write_table(out, "table06_cem.csv", paths)

  fixest::etable(fits,
                 file = file.path(paths$tables, "table06_cem.tex"),
                 title = "CEM-Matched DiD", label = "tab:cem",
                 style.tex = style.tex("aer"),
                 digits = 3, tex = TRUE, replace = TRUE)
  invisible(out)
}

# ---- DiD on point-contribution behavior (Table 7) ---------------------------
# analysis.do lines 777-781.
run_did_point_contribution <- function(paths) {
  user_day <- load_user_day(paths)
  specs <- intersect(c("log_consume_times", "log_consume_value"),
                     names(user_day))
  if (!length(specs)) {
    warning("[Table 7] consume_* columns missing; skipping.")
    out <- data.table()
    write_table(out, "table07_voting.csv", paths)
    return(invisible(out))
  }
  fits <- setNames(lapply(specs, function(dv)
    feols(make_did_formula(dv), data = user_day, cluster = ~uid)), specs)
  qs2::qs_save(fits, file.path(paths$models, "table07_voting.qs2"))

  out <- rbindlist(lapply(names(fits), function(nm)
    tidy_did(fits[[nm]], "table07", "voting", nm)))
  write_table(out, "table07_voting.csv", paths)

  fixest::etable(fits,
                 file = file.path(paths$tables, "table07_voting.tex"),
                 title = "Voting Behavior", label = "tab:voting",
                 style.tex = style.tex("aer"),
                 digits = 3, tex = TRUE, replace = TRUE)
  invisible(out)
}

# ---- IV / LATE on point-contribution uptake (Table 8) -----------------------
# analysis.do lines 2544-2561; analysis_tweet.do lines 1177-1184.
run_iv_late <- function(paths) {
  user_day <- load_user_day(paths)
  fit_late_iv <- function(dv) {
    feols(
      stats::as.formula(sprintf(
        "%s ~ consume_ind + after_1 | uid + date | int_consume_ind_after_1 ~ int_treat_1_after_1",
        dv
      )),
      data = user_day, cluster = ~uid
    )
  }

  specs <- intersect(
    c("log_post_original_num_in", "log_comment_num_in"),
    names(user_day)
  )
  have_iv_cols <- all(c("consume_ind", "int_consume_ind_after_1",
                        "int_treat_1_after_1") %in% names(user_day))

  if (!length(specs) || !have_iv_cols) {
    warning("[Table 8] IV columns missing; skipping LATE.")
    out <- data.table()
    write_table(out, "table08_late.csv", paths)
    return(invisible(out))
  }

  fits <- setNames(lapply(specs, function(dv) {
    tryCatch(fit_late_iv(dv), error = function(e) {
      warning(sprintf("[Table 8 / %s] IV failed: %s",
                      dv, conditionMessage(e)))
      NULL
    })
  }), specs)
  fits <- Filter(Negate(is.null), fits)

  if (!length(fits)) {
    warning("[Table 8] IV unidentified with proxy consume_ind. ",
            "Production replication requires data_consume.dta from coauthor; ",
            "see analysis.do line 2839.")
    out <- data.table()
    write_table(out, "table08_late.csv", paths)
    return(invisible(out))
  }

  qs2::qs_save(fits, file.path(paths$models, "table08_late.qs2"))
  out <- rbindlist(lapply(names(fits), function(nm)
    tidy_did(fits[[nm]], "table08", "LATE", nm)))
  write_table(out, "table08_late.csv", paths)
  invisible(out)
}

# ---- Wrapper: run all analyses in order -------------------------------------
run_all_analyses <- function(paths) {
  run_summary_stats(paths)
  run_pretreatment_balance(paths)
  run_did_content_quantity(paths)
  run_did_content_quality(paths)
  run_event_study(paths)
  run_cem_matched_did(paths)
  run_did_point_contribution(paths)
  run_iv_late(paths)
  cat("[02] analysis complete; CSVs in ", paths$tables, "\n")
  invisible(NULL)
}
