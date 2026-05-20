#' Function for back-compatibility with the facet/control args
#' @param ... inherited from parent function
#' @noRd
check_facet_control <- function(control, ...) {
  dots <- rlang::list2(...)

  if ("control" %in% names(dots) || !is.null(control)) {
    lifecycle::deprecate_warn(
      env = rlang::caller_env(),
      user_env = rlang::caller_env(2),
      when = "0.9.0",
      what = "polarMap(control)",
      with = "polarMap(type)",
      details = "This change has been made for better consistency with openair, and between dynamic and static maps."
    )
    if ("control" %in% names(dots)) {
      return(dots$control)
    } else {
      return(control)
    }
  }

  if ("facet" %in% names(dots)) {
    lifecycle::deprecate_warn(
      env = rlang::caller_env(),
      user_env = rlang::caller_env(2),
      when = "0.9.0",
      what = "polarMapStatic(facet)",
      with = "polarMap(type)",
      details = "This change has been made for better consistency with openair, and between dynamic and static maps. Note that static maps can now be produced using the 'static' argument of polarMap()"
    )
    return(dots$facet)
  }

  return(NULL)
}

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
      with = "openair::trajMap()",
      details = "This change has been made as the `openair` function is now written in `ggplot2`."
    )
    openair::trajPlot(...)$plot
  }
