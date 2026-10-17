#' Trajectory plots in `ggplot2`
#' @rdname deprecated-traj
#'
#' @description `r lifecycle::badge("deprecated")`
#'
#'   These functions existed at a time when [openair::trajPlot()] and
#'   [openair::trajLevel()] were written in `lattice`. Now they are written in
#'   `ggplot2`, these functions have been deprecated and now pass all of their
#'   arguments to their corresponding [openair] functions. They will be removed
#'   in a future version of `openairmaps`.
#'
#' @param ... Arguments passed to either [openair::trajPlot()] or
#'   [openair::trajLevel()].
#'
#' @export
#' @order 1
trajLevelMapStatic <-
  function(
    ...
  ) {
    lifecycle::deprecate_warn(
      env = rlang::caller_env(),
      user_env = rlang::caller_env(2),
      when = "0.10.1",
      what = "openairmaps::trajLevelMapStatic()",
      with = "openair::trajLevel()",
      details = "This change has been made as the `openair` function is now written in `ggplot2`."
    )
    openair::trajLevel(...)$plot
  }

#' @rdname deprecated-traj
#' @export
#' @order 2
trajMapStatic <-
  function(
    ...
  ) {
    lifecycle::deprecate_warn(
      env = rlang::caller_env(),
      user_env = rlang::caller_env(2),
      when = "0.10.1",
      what = "openairmaps::trajMapStatic()",
      with = "openair::trajPlot()",
      details = "This change has been made as the `openair` function is now written in `ggplot2`."
    )
    openair::trajPlot(...)$plot
  }
