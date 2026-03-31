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
