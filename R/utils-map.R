# Input checks -----------------------------------------------------------------

#' Check providers are valid
#' @noRd
check_providers <- function(provider, static) {
  providers_dict <- c(
    "OpenStreetMap" = "osm",
    "CyclOSM" = "opencycle",
    "OpenStreetMap.HOT" = "hotstyle",
    "WaymarkedTrails.hiking" = "loviniahike",
    "WaymarkedTrails.cycling" = "loviniacycle",
    "Stadia.StamenToner" = "stamenbw",
    "Stadia.StamenWatercolor" = "stamenwatercolor",
    "Thunderforest.OpenCycleMap" = "osmtransport",
    "Thunderforest.Landscape" = "thunderforestlandscape",
    "Thunderforest.Outdoors" = "thunderforestoutdoors",
    "CartoDB.DarkMatter" = "cartodark",
    "CartoDB.Positron" = "cartolight"
  )

  if (static) {
    provider <- provider %||% "osm"
    if (length(provider) > 1) {
      cli::cli_abort(
        c(
          "x" = "Static maps can only use a single {.arg provider}.",
          "i" = "You have provided {length(provider)}: {.val {provider}}."
        ),
        call = NULL
      )
    }
    if (provider %in% names(providers_dict)) {
      provider <- providers_dict[provider]
    }
    rlang::arg_match(provider, unname(providers_dict), multiple = FALSE)
  } else {
    provider <- provider %||% "OpenStreetMap"
    if (any(provider %in% providers_dict)) {
      for (i in seq_along(provider)) {
        if (provider[i] %in% providers_dict) {
          provider[i] <- unname(names(providers_dict)[
            providers_dict == provider[i]
          ])
        }
      }
    }
    rlang::arg_match(provider, names(leaflet::providers), multiple = TRUE)
  }
  return(provider)
}

#' Is `x` a single colour that R (and therefore leaflet) understands?
#' @noRd
is_colour <- function(x) {
  length(x) == 1 &&
    is.character(x) &&
    !inherits(try(grDevices::col2rgb(x), silent = TRUE), "try-error")
}

#' Check legend positions are valid
#' @noRd
check_legendposition <- function(position, static) {
  if (static) {
    settheme <- ggplot2::theme_get()
    setposition <- settheme$legend.position %||% "right"
    position <- position %||% setposition
    rlang::arg_match(
      position,
      c("top", "right", "bottom", "left"),
      multiple = FALSE
    )
  } else {
    position <- position %||% "topright"
    rlang::arg_match(
      position,
      c("topright", "topleft", "bottomright", "bottomleft"),
      multiple = FALSE
    )
  }
  return(position)
}

#' checks if multiple pollutants have been provided with a "fixed" scale
#' @param arg The name of the argument, for the warning.
#' @param warn Warn when falling back to `"free"`? Set to `FALSE` when `"fixed"`
#'   is just the default, rather than something the user asked for.
#' @noRd
check_multipoll <- function(vec, pollutant, arg = "limits", warn = TRUE) {
  if ("fixed" %in% vec && length(pollutant) > 1) {
    if (warn) {
      cli::cli_warn(
        c(
          "!" = "{.code {arg} = 'fixed'} only works with a single {.arg pollutant}.",
          "i" = "Using {.code {arg} = 'free'} instead."
        )
      )
    }
    "free"
  } else {
    vec
  }
}

#' Resolve a "fixed"/"free"/numeric colour or axis scale argument
#'
#' Several `*Map()` functions take an argument (e.g., `limits`, `breaks`,
#' `intervals`) which is either `"fixed"` (shared across all markers),
#' `"free"` (each marker has its own) or user-defined numeric values.
#' @param x The user-provided value.
#' @param arg The name of the argument, for error messages.
#' @param fixed The value to use for `"fixed"`. Only evaluated if needed, so
#'   can be an expensive computation (e.g., using `fixed_scale_data()`).
#' @param free The value to use for `"free"`.
#' @param n If the numeric vector must be a certain length, used in error
#'   messages.
#' @noRd
resolve_scale <- function(
  x,
  arg,
  fixed,
  free = NULL,
  n = NULL,
  call = rlang::caller_env()
) {
  if ("fixed" %in% x) {
    fixed
  } else if ("free" %in% x) {
    free
  } else if (is.numeric(x)) {
    x
  } else {
    vec <- if (is.null(n)) {
      "a numeric vector"
    } else {
      "a numeric vector of length {n}"
    }
    cli::cli_abort(
      c(
        "!" = "Do not recognise {.field {arg}} value of {.code {x}}",
        "i" = paste(
          "{.field {arg}} should be one of {.code 'fixed'}, {.code 'free'} or",
          vec
        )
      ),
      call = call
    )
  }
}

#' Run an openair function once over all markers' data
#'
#' Used to work out "fixed" scales: each marker becomes one panel, so the
#' returned data covers every marker and a shared scale can be calculated
#' from it.
#' @param fun An openair function (e.g., `openair::polarPlot`).
#' @param ... Passed to `fun`.
#' @returns The `$data` returned by `fun`.
#' @noRd
fixed_scale_data <- function(
  fun,
  data,
  pollutant,
  latitude,
  longitude,
  type,
  ...,
  call = rlang::caller_env()
) {
  check_pollutant(pollutant, call = call)

  data$latlng <- paste(data[[latitude]], data[[longitude]])

  fun(
    data,
    pollutant = pollutant,
    type = c("latlng", type %||% "default"),
    plot = FALSE,
    ...
  )$data
}

#' Check a pollutant has been provided
#' @noRd
check_pollutant <- function(pollutant, call = rlang::caller_env()) {
  if (is.null(pollutant)) {
    cli::cli_abort(
      c(
        "x" = "{.code pollutant} is missing with no default.",
        "i" = "Please provide a column of {.code data} which represents the pollutant(s) of interest."
      ),
      call = call
    )
  }
}

#' Check packages are installed for static mapping
#' @noRd
check_installed_static <- function() {
  rlang::check_installed(c(
    "ggspatial",
    "prettymapr",
    "ggtext",
    "png"
  ))
}

#' guess latlon
#' @param quiet Used to silence cli informs
#' @noRd
assume_latlon <- function(data, latitude, longitude, quiet = FALSE) {
  guess_latlon <- function(data, latlon = c("lat", "lon")) {
    x <- names(data)
    if (latlon == "lat") {
      name <- "latitude"
      str <- c("latitude", "latitud", "lat")
    } else if (latlon == "lon") {
      name <- "longitude"
      str <- c("longitude", "longitud", "lon", "long", "lng")
    }
    str <-
      c(str, toupper(str), tolower(str), stringr::str_to_title(str))
    id <- x %in% str
    out <- x[id]
    len <- length(out)
    if (len > 1) {
      cli::cli_abort(
        "Cannot identify {name}: Multiple possible matches ({out})",
        call = NULL
      )
    } else if (len == 0) {
      cli::cli_abort("Cannot identify {name}: No clear match.", call = NULL)
    } else {
      if (!quiet) {
        cli::cli_alert_info("Assuming {name} is '{out}'")
      }
      return(out)
    }
  }

  if (is.null(latitude) || is.null(longitude)) {
    if (is.null(latitude)) {
      latitude <- guess_latlon(data, "lat")
    } else {
      if (!quiet) {
        cli::cli_alert_success("Latitude provided as '{latitude}'")
      }
    }
    if (is.null(longitude)) {
      longitude <- guess_latlon(data, "lon")
    } else {
      if (!quiet) {
        cli::cli_alert_success("Longitude provided as '{longitude}'")
      }
    }
  }

  out <- list(latitude = latitude, longitude = longitude)
}


# Data preparation -------------------------------------------------------------

#' Prep data for mapping
#' @noRd
prepMapData <-
  function(
    data,
    pollutant,
    control,
    ...,
    .to_narrow = TRUE,
    .pairwise = FALSE
  ) {
    check_pollutant(pollutant)

    ## extract variables of interest
    vars <- unique(c(pollutant, control, ...))

    # check and select variables - other checks (e.g., of wind data) are done
    # by openair when drawing each marker
    missing <- setdiff(vars, names(data))
    if (length(missing) > 0) {
      cli::cli_abort(
        "Can't find the variable{?s} {.field {missing}} in {.arg data}."
      )
    }
    data <- data[vars]

    # infinite values (e.g., from ratios) would break shared colour scales
    data[pollutant] <- lapply(data[pollutant], \(x) {
      replace(x, is.infinite(x), NA)
    })

    # check if more than one pollutant & is.null split
    if (length(pollutant) > 1 && !is.null(control) && !.pairwise) {
      cli::cli_warn(
        c(
          "!" = "Multiple pollutants {.emph and} {.code type} option specified",
          "i" = "Please only specify multiple pollutants {.emph or} a {.code type} option",
          "i" = "Defaulting to splitting by {.code pollutant}"
        )
      )
    }

    if (.to_narrow) {
      # pollutants to long
      data <-
        tidyr::pivot_longer(
          data = data,
          cols = dplyr::all_of(pollutant),
          names_to = "pollutant_name",
          values_to = "conc"
        )

      # make pollutant names factors, in the order they were given
      data <-
        dplyr::mutate(
          .data = data,
          pollutant_name = factor(.data$pollutant_name, levels = pollutant)
        )
    }

    return(data)
  }

#' get breaks for the "rose" functions
#' @param breaks as given by windrose
#' @param ws.int as given by windrose
#' @param vec the vector to calc max/min/q90
#' @param polrose use pollutionrose method? T/F
#' @noRd
getBreaks <- function(breaks, ws.int, vec, polrose) {
  if (is.numeric(breaks) && length(breaks) == 1 && polrose) {
    breaks <- unique(pretty(
      c(
        min(vec, na.rm = TRUE),
        stats::quantile(vec, probs = 0.9, na.rm = TRUE)
      ),
      breaks
    ))
  }
  if (length(breaks) == 1) {
    breaks <- 0:(breaks - 1) * ws.int
  }
  if (max(breaks) < max(vec, na.rm = TRUE)) {
    breaks <- c(breaks, max(vec, na.rm = TRUE))
  }
  breaks <- unique(breaks)
  breaks <- sort(breaks)
  breaks
}

#' function to quickly combine multiple popups together
#' @param data,popup,latitude,longitude,control inherited from parent. Any
#'   names of `popup` are used as-is; otherwise, they are tidied column names.
#' @param name The name of the new popup column - `".popup"` by default, so it
#'   can't clash with a user's column (e.g., one called `"popup"`).
#' @noRd
quick_popup <- function(
  data,
  popup,
  latitude,
  longitude,
  control,
  name = ".popup"
) {
  nice_popup <-
    stringr::str_replace_all(popup, "\\_|\\.|\\-", " ") |>
    stringr::str_to_title()
  nms <- rlang::names2(popup)
  has_name <- !is.na(nms) & nms != ""
  nice_popup[has_name] <- nms[has_name]

  names <- stats::setNames(popup, nice_popup)

  buildPopup(
    data,
    columns = names,
    latitude = latitude,
    longitude = longitude,
    type = control,
    name = name
  )
}

#' Label numeric popup columns as averages, e.g., `"nox (mean)"`
#'
#' `buildPopup()` averages numeric columns at each marker, so unnamed numeric
#' `popup` columns (other than the coordinates) are named to say so.
#' @returns `popup`, with names added where needed.
#' @noRd
label_mean_popups <- function(popup, data, latitude, longitude) {
  popup <- rlang::set_names(popup, rlang::names2(popup))
  is_mean <- rlang::names2(popup) == "" &
    !popup %in% c(latitude, longitude) &
    purrr::map_lgl(popup, \(x) is.numeric(data[[x]]))
  names(popup)[is_mean] <- paste(popup[is_mean], "(mean)")
  popup
}

#' Format a number as an ordinal, e.g., `"1st"`, `"12th"` or `"95th"`
#' @noRd
ordinal <- function(x) {
  # 11th, 12th & 13th are exceptions to 1st, 2nd & 3rd, and decimals (e.g.,
  # 92.5th) always use "th"
  suffix <- ifelse(
    x %% 100 %in% 11:13 | x %% 1 != 0,
    "th",
    c("th", "st", "nd", "rd", rep("th", 6))[x %% 10 + 1]
  )
  paste0(x, suffix)
}

#' Error when markers have more than one popup/label
#' @param by The arguments which define a single marker.
#' @noRd
abort_multiple_popups <- function(
  by = c("latitude", "longitude"),
  call = rlang::caller_env()
) {
  by <- paste(by, collapse = "/")
  cli::cli_abort(
    c(
      "x" = "Multiple popups/labels per {.code {by}} combination.",
      "i" = "Have you used a numeric column, e.g., a pollutant concentration?",
      "i" = "Consider using {.fun buildPopup} to easily create distinct popups per marker."
    ),
    call = call
  )
}


# Polar markers ----------------------------------------------------------------

#' Give polar markers a transparent panel, unless the user says otherwise
#'
#' Some openair plots have a panel background (e.g., `openair::windRose()`'s
#' is white), which would hide the map behind the marker. This is removed via
#' openair's `theme` argument, rather than after plotting, so that users can
#' still choose a panel background through `theme`:
#'
#' - `"default"` (or `NULL`) becomes a transparent panel.
#' - A `ggplot2::theme()` is added to a transparent panel, so any
#'   `panel.background` it sets takes precedence.
#' - Any other preset (e.g., `"dark"`) is used as-is.
#' @noRd
marker_theme <- function(theme) {
  transparent <- ggplot2::theme(
    panel.background = ggplot2::element_rect(fill = NA)
  )
  theme <- theme %||% "default"
  if (ggplot2::is_theme(theme)) {
    return(transparent + theme)
  }
  if (identical(theme, "default")) {
    return(transparent)
  }
  theme
}

#' Create markers for the static plots
#' @param fun An openair function (e.g., `openair::polarPlot`), called with
#'   `mydata` - or `before` and `after` if `after` is provided - and
#'   `fun_args`.
#' @param fun_args A list of other arguments to pass to `fun`.
#' @param after optionally, a second data frame for two-table plots (i.e.,
#'   `polarDiff()`). `data` is then the "before" case, and provides any
#'   popups/labels.
#' @param latitude,longitude,split_col,d.fig inherited from parent
#' @noRd
create_polar_markers <-
  function(
    fun,
    fun_args,
    data,
    latitude,
    longitude,
    split_col,
    popup = NULL,
    label = NULL,
    d.fig,
    dropcol = "conc",
    after = NULL,
    progress = TRUE
  ) {
    # sort out popups/labels - placeholders are dot-prefixed, so they can't
    # overwrite a user's column (e.g., `popup = "label"`)
    if (is.null(popup)) {
      data$.popup <- "NA"
      popup <- ".popup"
    }
    if (is.null(label)) {
      data$.label <- "NA"
      label <- ".label"
    }

    # markers sit on a map, so shouldn't have a panel background
    fun_args$theme <- marker_theme(fun_args$theme)

    # drop missing data
    data <- tidyr::drop_na(data, dplyr::all_of(dropcol))

    # get number of rows
    valid_rows <-
      nrow(dplyr::distinct(
        data,
        .data[[latitude]],
        .data[[longitude]],
        .data[[split_col]]
      ))

    # nest data
    nested_df <- data |>
      tidyr::nest(
        data = -dplyr::all_of(c(
          latitude,
          longitude,
          split_col,
          popup,
          label
        ))
      )

    # check for popup issues
    if (nrow(nested_df) > valid_rows) {
      abort_multiple_popups(by = c("latitude", "longitude", "type"))
    }

    # pair up with "after" data for two-table plots
    if (!is.null(after)) {
      keys <- c(latitude, longitude, split_col)

      after <- tidyr::drop_na(after, dplyr::all_of(dropcol))
      nested_after <- tidyr::nest(after, after = -dplyr::all_of(keys))

      # warn if missing
      unmatched <-
        dplyr::bind_rows(
          dplyr::anti_join(nested_df, nested_after, by = keys),
          dplyr::anti_join(nested_after, nested_df, by = keys)
        )
      if (nrow(unmatched) > 0) {
        warn_df <- unmatched |>
          tidyr::unite("warning", dplyr::all_of(keys), sep = "/") |>
          dplyr::distinct(.data$warning)

        cli::cli_warn(
          c(
            "!" = "Not all {.code latitude}/{.code longitude}/{.code type} combinations in {.code before} matched in {.code after}.",
            "i" = "Not matched: {.field {warn_df$warning}}"
          )
        )
      }

      nested_df <- dplyr::inner_join(nested_df, nested_after, by = keys)
    }

    # unique file for each marker
    plots_df <- nested_df
    plots_df$url <- vapply(
      seq_len(nrow(plots_df)),
      \(i) tempfile("openairmaps_", fileext = ".png"),
      character(1)
    )

    dims <- marker_dims(d.fig)

    # create and save plots
    plots_df$plot <-
      purrr::pmap(
        .l = dplyr::select(plots_df, dplyr::any_of(c("data", "after", "url"))),
        .f = purrr::in_parallel(
          function(data, url, after = NULL) {
            openair_obj <- tryCatch(
              error = function(cnd) {},
              # (not `rlang::exec(!!!)`, as in_parallel() would inject it
              # too early)
              if (is.null(after)) {
                do.call(fun, c(list(mydata = data), fun_args))
              } else {
                do.call(fun, c(list(before = data, after = after), fun_args))
              }
            )

            if (!is.null(openair_obj)) {
              # save plot
              ggplot2::ggsave(
                plot = openair_obj$plot +
                  ggplot2::theme(
                    plot.background = ggplot2::element_blank(),
                    plot.margin = ggplot2::unit(rep(0, 4), "cm"),
                    legend.background = ggplot2::element_blank(),
                    legend.title = ggplot2::element_blank()
                  ),
                filename = url,
                width = dims$width * 0.75,
                height = dims$height * 0.75,
                dpi = 72,
                bg = "transparent"
              )
              return(openair_obj$data)
            }
          },
          fun = fun,
          fun_args = fun_args,
          dims = dims
        ),
        .progress = progress
      )

    return(plots_df)
  }

#' Attach rendered marker icons to a leaflet map
#'
#' This is the single implementation of "what an openair marker looks like on
#' a leaflet map" (icon sizing, anchoring, popups/labels, alpha, dropping rows
#' where no plot could be rendered). `addPolarMarkers()`/`addPolarDiffMarkers()`
#' (the low-level, user-facing entry point) and `make_leaflet_map()` (used
#' internally by the high-level `*Map()` family) both call this rather than
#' each re-implementing marker assembly - keeping a single source of truth so
#' the two public entry points can't drift apart.
#'
#' @param data A data frame as produced by `create_polar_markers()` - must
#'   contain a `url` column (and `plot`, used to drop rows where rendering
#'   failed).
#' @param group_col Optionally, a column of `data` giving each marker's group,
#'   used instead of `group`. Unlike a vector passed to `group`, this stays
#'   aligned with the markers when rows without a plot are dropped.
#' @param latitude,longitude,d.icon,group,layerId,popup,popupOptions,label,
#'   labelOptions,options,clusterOptions,clusterId,alpha as in
#'   `addPolarMarkers()`/[leaflet::addMarkers()].
#' @noRd
attach_marker_icons <-
  function(
    map,
    data,
    latitude,
    longitude,
    d.icon,
    group = NULL,
    group_col = NULL,
    layerId = NULL,
    popup = NULL,
    popupOptions = NULL,
    label = NULL,
    labelOptions = NULL,
    options = leaflet::markerOptions(),
    clusterOptions = NULL,
    clusterId = NULL,
    alpha = 1
  ) {
    dims <- marker_dims(d.icon)

    # handle alpha
    options$opacity <- alpha

    # drop data where no plot was created
    data <- data[has_plot(data), ]

    if (nrow(data) == 0L) {
      cli::cli_warn("No valid polar markers were created.")
      return(map)
    }

    # get marker arguments
    marker_arg <- list(
      map = map,
      lat = data[[latitude]],
      lng = data[[longitude]],
      icon = leaflet::makeIcon(
        iconUrl = data$url,
        iconHeight = dims$height,
        iconWidth = dims$width,
        iconAnchorX = dims$width / 2,
        iconAnchorY = dims$height / 2,
        popupAnchorX = -.Machine$double.eps,
        popupAnchorY = -(dims$height / 2) * 0.7
      ),
      group = if (!is.null(group_col)) data[[group_col]] else group,
      layerId = layerId,
      popupOptions = popupOptions,
      labelOptions = labelOptions,
      options = options,
      clusterOptions = clusterOptions,
      clusterId = clusterId
    )

    # deal w/ popups/labels
    if (!is.null(popup)) {
      marker_arg <- append(marker_arg, list(popup = data[[popup]]))
    }
    if (!is.null(label)) {
      marker_arg <- append(marker_arg, list(label = data[[label]]))
    }

    # add markers to map
    rlang::exec(leaflet::addMarkers, !!!marker_arg)
  }

#' Expand a `d.icon`/`d.fig` value into a width and height
#'
#' A single value is used for both; otherwise, `c(width, height)`.
#' @noRd
marker_dims <- function(d) {
  d <- rep_len(d, 2)
  list(width = d[[1]], height = d[[2]])
}

#' Which markers were successfully plotted?
#'
#' `create_polar_markers()` leaves `plot` as `NULL` where openair couldn't draw
#' a marker (e.g., there wasn't enough data).
#' @noRd
has_plot <- function(plots_df) {
  !vapply(plots_df$plot, is.null, logical(1))
}

#' Resolve colour `breaks` once, across all polar markers
#'
#' openair works out binned colour scales from each plot's own modelled
#' surface, so markers given e.g. `breaks = 5` would each end up with different
#' intervals and no shared legend could be drawn. This mirrors the approach of
#' `limits = "fixed"`: the openair function is run once on all of the data,
#' with one panel per marker, so that a single set of breakpoints is calculated.
#' These are then returned (alongside any user-defined labels) to be passed to
#' each individual marker, so all markers share identical intervals.
#'
#' openair doesn't return the numeric breakpoints it calculates, so they are
#' parsed from its default interval labels (e.g., `"15 to 64"`). This is why
#' any user-defined labels are left out of the initial run.
#'
#' @param fun The openair function (e.g., `openair::polarPlot`).
#' @param fun_args The arguments used to draw each marker.
#' @param data The prepped data (i.e., the output of `prepMapData()`).
#' @param breaks The user-provided `breaks`; a numeric vector, a single number,
#'   or a list from `openair::breakOpts()`.
#' @param values A function to extract the colour variable from the data
#'   returned by `fun` (e.g., `\(x) x$z`).
#' @returns A list to pass to the `breaks` argument of `fun`.
#' @noRd
resolve_shared_breaks <- function(
  fun,
  fun_args,
  data,
  breaks,
  values,
  latitude,
  longitude,
  split_col
) {
  opts <- if (is.list(breaks)) breaks else list(breaks = breaks)
  labels <- opts$labels

  # one panel per marker, with default labels so they can be parsed
  data$.marker <- paste(data[[latitude]], data[[longitude]], data[[split_col]])
  args <- fun_args
  args$type <- ".marker"
  args$labels <- NULL
  args$breaks <- utils::modifyList(opts, list(labels = NULL), keep.null = TRUE)

  pooled <- rlang::exec(fun, mydata = data, !!!args)$data
  intervals <- levels(values(pooled))

  bounds <- strsplit(intervals, " to ", fixed = TRUE)
  lower <- suppressWarnings(as.numeric(vapply(bounds, `[`, "", 1)))
  upper <- suppressWarnings(as.numeric(vapply(bounds, `[`, "", 2)))

  if (
    is.null(intervals) ||
      anyNA(lower) ||
      anyNA(upper) ||
      any(lengths(bounds) != 2)
  ) {
    cli::cli_abort(
      c(
        "x" = "Could not work out a shared set of {.arg breaks} for all polar markers.",
        "i" = "Try providing a numeric vector of {.arg breaks} instead."
      )
    )
  }

  # the outer breaks are open-ended so that openair never extends them to
  # cover an individual marker's data (which would change that marker's
  # labels), and so the precision of the parsed labels doesn't matter. The
  # labels from the initial run are kept so the true range is still shown.
  opts$breaks <- c(-Inf, lower[-1], Inf)
  opts$labels <- labels %||% intervals
  opts
}


# Interactive maps -------------------------------------------------------------

#' make leaflet map from scratch
#' @noRd
make_leaflet_map <-
  function(
    data,
    latitude,
    longitude,
    crs,
    provider,
    d.icon,
    popup,
    label,
    split_col,
    control.collapsed,
    control.position,
    control.autotext,
    alpha
  ) {
    if (control.autotext) {
      textfun <- quickTextHTML
    } else {
      textfun <- identity
    }

    # attach_marker_icons() expects explicit lat/lng columns rather than
    # relying on sf geometry
    data <- as_lnglat(data, latitude, longitude, crs)

    # create map
    map <- leaflet::leaflet(data) |>
      add_basemaps(provider)

    # add markers
    data$.group <- textfun(data[[split_col]])
    map <- attach_marker_icons(
      map = map,
      data = data,
      latitude = latitude,
      longitude = longitude,
      d.icon = d.icon,
      group_col = ".group",
      popup = popup,
      label = label,
      alpha = alpha
    )

    # add layer control menu - only for groups where a plot was created
    map <- add_layer_control(
      map,
      provider = provider,
      groups = textfun(level_order(data[[split_col]][has_plot(data)])),
      position = control.position,
      collapsed = control.collapsed
    )

    return(map)
  }

#' Reproject latitude/longitude columns to EPSG:4326
#'
#' `latitude` and `longitude` are overwritten with their EPSG:4326
#' coordinates, so data in any `crs` can be placed on a lat/lng map.
#' @noRd
as_lnglat <- function(data, latitude, longitude, crs) {
  coords <-
    sf::st_as_sf(data, coords = c(longitude, latitude), crs = crs) |>
    sf::st_transform(crs = 4326) |>
    sf::st_coordinates()
  data[[longitude]] <- coords[, "X"]
  data[[latitude]] <- coords[, "Y"]
  data
}

#' The unique values of `x`, in order
#'
#' Factors keep the order of their levels (e.g., `"Monday"` before `"Tuesday"`
#' when `type = "weekday"`), dropping any unused ones. Anything else is sorted.
#' Used to order the groups of a "layer control" menu.
#' @noRd
level_order <- function(x) {
  if (is.factor(x)) {
    return(levels(droplevels(x)))
  }
  sort(unique(x))
}

#' Name a vector of leaflet providers
#'
#' Any unnamed providers are named after themselves, so users can (partially)
#' label their basemaps, e.g., `c("Default" = "OpenStreetMap", "Esri.WorldGrayCanvas")`.
#' @noRd
name_providers <- function(provider) {
  provider <- provider[!duplicated(provider)]
  nms <- names(provider) %||% rep("", length(provider))
  nms[is.na(nms) | nms == ""] <- provider[is.na(nms) | nms == ""]
  stats::setNames(provider, nms)
}

#' Add one or more provider tiles to a leaflet map
#'
#' Each provider is added as its own group (named via `name_providers()`), so
#' that `add_layer_control()` can switch between them.
#' @noRd
add_basemaps <- function(map, provider) {
  provider <- name_providers(provider)
  for (i in seq_along(provider)) {
    map <- leaflet::addProviderTiles(
      map,
      provider = provider[[i]],
      group = names(provider)[[i]]
    )
  }
  map
}

#' Add a layer control menu to a leaflet map
#'
#' The one place the "layer control" menu is built, so that all openairmaps
#' functions behave the same:
#'
#' - `groups` are the map's own layers (e.g., `type` levels or pollutants).
#'   They are base groups (radio buttons) when `groups_as = "base"`, or overlay
#'   groups (checkboxes) when `groups_as = "overlay"`.
#' - Multiple providers are base groups unless `groups` already are, in which
#'   case they become overlays. Only the first provider is shown initially.
#' - A single base group is never shown, as there is nothing to switch to. If
#'   there is nothing to show at all, no menu is added.
#' @noRd
add_layer_control <- function(
  map,
  provider,
  groups = NULL,
  groups_as = c("base", "overlay"),
  position = "topright",
  collapsed = FALSE
) {
  groups_as <- rlang::arg_match(groups_as)
  provider <- names(name_providers(provider))
  groups <- as.character(groups)

  base_groups <- character(0)
  overlay_groups <- character(0)

  if (groups_as == "base" && length(groups) > 1) {
    base_groups <- groups
    if (length(provider) > 1) {
      overlay_groups <- provider
    }
  } else {
    if (groups_as == "overlay") {
      overlay_groups <- groups
    }
    if (length(provider) > 1) {
      base_groups <- provider
    }
  }

  if (length(base_groups) == 0 && length(overlay_groups) == 0) {
    return(map)
  }

  map <- leaflet::addLayersControl(
    map,
    position = position,
    baseGroups = base_groups,
    overlayGroups = overlay_groups,
    options = leaflet::layersControlOptions(
      collapsed = collapsed,
      autoZIndex = FALSE
    )
  )

  if (length(provider) > 1) {
    map <- leaflet::hideGroup(map, provider[-1])
  }

  map
}


# Static maps ------------------------------------------------------------------

#' theme for static maps
#' @noRd
theme_static <- function() {
  ggplot2::`%+replace%`(
    ggplot2::theme_minimal(),
    ggplot2::theme(
      panel.border = ggplot2::element_rect(fill = NA, color = "black")
    )
  )
}

#' if ggmap is not provided, have a guess
#' @param data `plots_sf` input
#' @noRd
estimate_bbox <-
  function(data) {
    bbox <- sf::st_bbox(data) |> as.list()
    xdiff <- abs(bbox$xmin - bbox$xmax) / 2
    ydiff <- abs(bbox$ymin - bbox$ymax) / 2
    diff <- mean(c(xdiff, ydiff))
    bbox$xmin <- bbox$xmin - diff
    bbox$xmax <- bbox$xmax + diff
    bbox$ymin <- bbox$ymin - diff
    bbox$ymax <- bbox$ymax + diff
    return(bbox)
  }

#' Create static map
#' @param latitude:facet.nrow inherited from parent
#' @param plots_df `plots_df`
#' @noRd
create_static_map <-
  function(
    plots_df,
    latitude,
    longitude,
    crs,
    provider,
    split_col,
    pollutant,
    d.icon,
    facet,
    facet.nrow,
    api_key,
    alpha
  ) {
    # silence R CMD check
    makebbox <- prettymapr::makebbox(1, 1, 1, 1)

    dims <- marker_dims(d.icon)

    # drop data where no plot was created
    plots_df <- plots_df[has_plot(plots_df), ]

    if (nrow(plots_df) == 0L) {
      cli::cli_abort("No valid polar markers were created.")
    }

    # don't turn facet levels into chr, keep as fct
    if (length(pollutant) > 1 || !is.null(facet)) {
      levels(plots_df[[split_col]]) <- quickTextHTML(levels(plots_df[[
        split_col
      ]]))
    }

    # turn into sf object
    plots_sf <-
      sf::st_as_sf(
        plots_df,
        coords = c(longitude, latitude),
        crs = crs,
        remove = FALSE
      ) |>
      sf::st_transform(crs = 4326)

    # apply transparency, if requested
    if (alpha < 1) {
      for (x in plots_sf$url) {
        png::writePNG(set_png_alpha(png::readPNG(x), alpha), x)
      }
    }

    # create link to image
    plots_sf$link <- stringr::str_glue(
      "<img src='{plots_sf$url}' width='{dims$width}' height='{dims$height}'/>"
    )

    # work out an approximate bounding box for the plot
    bbox <- estimate_bbox(plots_sf)

    # make plot
    plt <-
      ggplot2::ggplot(plots_sf) +
      ggspatial::annotation_map_tile(
        zoomin = 0,
        cachedir = tempdir(),
        type = provider,
        progress = "none",
        api_key = api_key
      ) +
      geom_sf_richtext(
        data = plots_sf,
        ggplot2::aes(label = .data[["link"]]),
        fill = NA,
        color = NA,
        # the markers are already points, so don't need to be placed "on
        # surface" (which warns for latitude/longitude data)
        fun.geometry = sf::st_zm
      ) +
      theme_static() +
      ggplot2::coord_sf(
        xlim = c(bbox$xmin, bbox$xmax),
        ylim = c(bbox$ymin, bbox$ymax)
      ) +
      ggplot2::labs(x = NULL, y = NULL)

    if (
      length(pollutant) > 1 ||
        !is.null(facet)
    ) {
      plt <-
        plt +
        ggplot2::facet_wrap(
          ggplot2::vars(.data[[split_col]]),
          nrow = facet.nrow
        ) +
        ggplot2::theme(strip.text = ggtext::element_markdown())
    }

    return(plt)
  }

#' Multiply the opacity of an image by `alpha`
#'
#' @param img An image array, as returned by [png::readPNG()]: greyscale
#'   (a matrix), greyscale + alpha, RGB or RGBA. Any image without an alpha
#'   channel is given one.
#' @returns An image array with an alpha channel as its last channel.
#' @noRd
set_png_alpha <- function(img, alpha) {
  # greyscale images are matrices, rather than arrays with one channel
  if (length(dim(img)) == 2) {
    img <- array(img, dim = c(dim(img), 1))
  }

  # greyscale/RGB images have no alpha channel, so add an opaque one
  channels <- dim(img)[3]
  if (channels %in% c(1, 3)) {
    opaque <- array(1, dim = c(dim(img)[1:2], channels + 1))
    opaque[,, seq_len(channels)] <- img
    img <- opaque
  }

  n <- dim(img)[3]
  img[,, n] <- img[,, n] * alpha
  img
}

#' a combination of geom_sf and geom_richtext
#'
#' @author StuieT85 on GitHub
#' @source https://github.com/wilkelab/ggtext/issues/76#issuecomment-1011166509
#' @noRd
geom_sf_richtext <-
  function(
    mapping = ggplot2::aes(),
    data = NULL,
    stat = "sf_coordinates",
    position = "identity",
    ...,
    parse = FALSE,
    nudge_x = 0,
    nudge_y = 0,
    label.padding = ggplot2::unit(0.25, "lines"),
    label.r = ggplot2::unit(
      0.15,
      "lines"
    ),
    label.size = 0.25,
    na.rm = FALSE,
    show.legend = NA,
    inherit.aes = TRUE,
    fun.geometry = NULL
  ) {
    if (!missing(nudge_x) || !missing(nudge_y)) {
      if (!missing(position)) {
        cli::cli_abort(
          "Specify either {.arg position} or {.arg nudge_x}/{.arg nudge_y}"
        )
      }
      position <- ggplot2::position_nudge(nudge_x, nudge_y)
    }
    ggplot2::layer_sf(
      data = data,
      mapping = mapping,
      stat = stat,
      geom = ggtext::GeomRichText,
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = list(
        label.padding = label.padding,
        label.r = label.r,
        label.size = label.size,
        na.rm = na.rm,
        fun.geometry = fun.geometry,
        ...
      )
    )
  }


# Legends ----------------------------------------------------------------------

#' Create a legend title
#' @noRd
create_legend_title <- function(
  static,
  legend.title.autotext,
  legend.title,
  str
) {
  legend.title <- legend.title %||% str
  if (!legend.title.autotext) {
    return(legend.title)
  }
  if (static) openair::quickText(legend.title) else quickTextHTML(legend.title)
}

#' Legend specifications for polar marker maps
#'
#' openair polar plots are either *continuous* (a numeric colour scale between
#' `limits`) or *discrete* (binned into labelled intervals using `breaks`).
#' These describe the shared legend for a map of many markers, which
#' `add_polar_legend()` then draws on a leaflet or ggplot2 map.
#'
#' Colours match those openair uses: `openColours(cols)` stretched between the
#' limits for continuous scales, and `openColours(cols, n = <n intervals>)` for
#' discrete ones.
#' @noRd
legend_continuous <- function(limits, cols) {
  list(type = "continuous", limits = limits, cols = cols)
}

#' @rdname legend_continuous
#' @noRd
legend_discrete <- function(labels, cols) {
  list(
    type = "discrete",
    labels = labels,
    colours = openair::openColours(scheme = cols, n = length(labels))
  )
}

#' Work out the shared legend from the markers themselves
#'
#' `values` extracts the colour variable from the data returned by the openair
#' function for each marker (e.g., `z` for `polarPlot()`). If this is a factor,
#' the scale is discrete and a legend can be drawn as long as every marker
#' shares the same intervals. If it is numeric, a legend can only be drawn if a
#' shared set of `limits` has been used. Otherwise, each marker has its own
#' scale so there's no shared legend to draw, and `NULL` is returned.
#'
#' `trans` is the colour scale transform used by openair (e.g., `"log10"`).
#' Continuous legends are drawn on a linear scale, so would be misleading for
#' transformed markers and aren't drawn. Discrete legends are unaffected, as
#' openair bins the untransformed values.
#' @noRd
legend_from_markers <- function(
  plots_df,
  values,
  limits = NULL,
  cols,
  trans = FALSE
) {
  vals <- lapply(Filter(Negate(is.null), plots_df$plot), values)
  if (length(vals) == 0) {
    return(NULL)
  }

  if (all(vapply(vals, is.factor, logical(1)))) {
    lvls <- unique(lapply(vals, levels))
    if (length(lvls) > 1) {
      return(NULL)
    }
    return(legend_discrete(lvls[[1]], cols))
  }

  if (!is.null(limits) && length(limits) == 2 && !anyNA(limits)) {
    if (!isFALSE(trans)) {
      cli::cli_inform(
        c(
          "i" = "No shared legend has been drawn as the colour scale has been transformed using {.arg trans}.",
          "i" = "Set {.code trans = FALSE} or provide {.arg breaks} to draw a shared legend."
        )
      )
      return(NULL)
    }
    return(legend_continuous(limits, cols))
  }

  NULL
}

#' Get the colour intervals of an openair wind/pollution rose
#'
#' `windRose()` and `pollutionRose()` return their intervals as an attribute
#' of their data, rather than a column. For use with `legend_from_markers()`.
#' @noRd
rose_intervals <- function(data) {
  intervals <- attr(data, "intervals")
  factor(intervals, intervals)
}

#' Add a polar marker legend to a leaflet or ggplot2 map
#'
#' The one place shared polar marker legends are drawn, so they look the same
#' across `polarMap()`, `annulusMap()`, etc.
#' @param spec A legend specification, from `legend_continuous()`,
#'   `legend_discrete()` or `legend_from_markers()`. If `NULL`, no legend is
#'   drawn.
#' @param plots_df,latitude,longitude,crs Only needed for static maps, which
#'   need some (invisible) data to attach a legend to.
#' @noRd
add_polar_legend <- function(
  map,
  spec,
  static,
  title,
  position,
  alpha = 1,
  plots_df = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326
) {
  if (is.null(spec)) {
    return(map)
  }

  if (!static) {
    if (spec$type == "continuous") {
      return(leaflet::addLegend(
        map,
        title = title,
        position = position,
        opacity = alpha,
        pal = leaflet::colorNumeric(
          palette = openair::openColours(scheme = spec$cols),
          domain = spec$limits
        ),
        values = spec$limits
      ))
    }

    # leaflet legends don't understand 8-digit (transparent) hex codes
    colours <- grDevices::rgb(
      t(grDevices::col2rgb(spec$colours)),
      maxColorValue = 255
    )
    return(leaflet::addLegend(
      map,
      title = title,
      position = position,
      opacity = alpha,
      colors = colours,
      labels = spec$labels
    ))
  }

  # static maps need a layer for the legend to belong to - use invisible points
  # at the marker locations (reprojected, like the markers themselves)
  points <-
    dplyr::distinct(plots_df, .data[[longitude]], .data[[latitude]]) |>
    as_lnglat(latitude, longitude, crs)

  if (spec$type == "continuous") {
    return(
      map +
        ggplot2::geom_point(
          data = points,
          ggplot2::aes(.data[[longitude]], .data[[latitude]], color = 0),
          alpha = 0
        ) +
        ggplot2::scale_color_gradientn(
          limits = spec$limits,
          colours = openair::openColours(scheme = spec$cols)
        ) +
        ggplot2::labs(color = title) +
        ggplot2::theme(legend.position = position)
    )
  }

  intervals <- factor(spec$labels, spec$labels)
  dummy <- tidyr::crossing(points, intervals)

  map +
    ggplot2::geom_point(
      data = dummy,
      ggplot2::aes(
        .data[[longitude]],
        .data[[latitude]],
        color = .data[["intervals"]],
        fill = .data[["intervals"]]
      ),
      size = 0,
      key_glyph = ggplot2::draw_key_rect
    ) +
    ggplot2::scale_color_manual(
      values = stats::setNames(spec$colours, spec$labels),
      drop = FALSE,
      aesthetics = c("color", "fill")
    ) +
    ggplot2::labs(color = title, fill = title) +
    ggplot2::theme(legend.position = position)
}


# Trajectories -----------------------------------------------------------------

#' Identify individual trajectories
#'
#' Trajectories are identified by their arrival `date` and, if present, their
#' `receptor` (as returned by `openair::importTraj()`), so that trajectories
#' arriving at different receptors at the same time aren't joined together.
#' @noRd
traj_id <- function(data) {
  cols <- intersect(c("date", "receptor"), names(data))
  interaction(data[cols], drop = TRUE, lex.order = TRUE)
}

# Trajectory popups ------------------------------------------------------------

#' Build the default trajectory popup label
#'
#' Shared by [addTrajPaths()] and [trajMap()] so the two don't drift apart.
#' Styled to match the [networkMap()] popups.
#' @param extra Optional name of an additional column to show (e.g., the
#'   pollutant used to colour the trajectories).
#' @param lat,lng The names of the latitude and longitude columns.
#' @noRd
build_traj_labels <- function(data, extra = NULL, lat = "lat", lng = "lon") {
  extra_row <- ""
  if (!is.null(extra)) {
    extra_row <- popup_section(popup_row(quickTextHTML(extra), data[[extra]]))
  }

  data$lab <- popup_card(
    title = format(data$date, "%Y-%m-%d %H:%M"),
    subtitle = "ARRIVAL DATE",
    popup_row("Trajectory date", format(data$date2, "%Y-%m-%d %H:%M")),
    popup_row("Latitude", data[[lat]]),
    popup_row("Longitude", data[[lng]]),
    popup_row("Height", paste(data$height, "m")),
    popup_row("Pressure", paste(data$pressure, "hPa")),
    extra_row
  )

  data
}

#' Build the default gridded trajectory popup label
#'
#' Used by [addTrajLevel()]. Styled to match `build_traj_labels()`.
#' @param data The output of `openair::trajLevel()`, with `label` (the
#'   formatted value) and `gridcount` columns.
#' @param subtitle Description of the statistic shown under the value.
#' @param type Optional name of the conditioning column to show.
#' @noRd
build_traj_level_labels <- function(data, subtitle, type = NULL) {
  count_row <- ifelse(
    is.na(data$gridcount),
    "",
    popup_row("Count", data$gridcount)
  )

  type_row <- ""
  if (!is.null(type)) {
    type_row <- popup_section(popup_row(quickTextHTML(type), data[[type]]))
  }

  popup_card(
    title = data$label,
    subtitle = subtitle,
    popup_row("Latitude", data$ygrid),
    popup_row("Longitude", data$xgrid),
    count_row,
    type_row
  )
}

#' Shared building blocks for popups
#'
#' Used by the trajectory functions, [networkMap()] and [buildPopup()] so their
#' popups look the same. `popup_container()` sets the font and scrolling,
#' `popup_card()` wraps rows in it with a bold title + caption header,
#' `popup_row()` is a single grey-label/value row, and `popup_section()`
#' separates rows from those above with a thin divider. All are vectorised.
#' @param width The width of the card, in pixels.
#' @param colour Optionally, a colour used for a dot next to the title and for
#'   the subtitle (e.g., to identify a monitoring network).
#' @noRd
popup_card <- function(title, subtitle, ..., width = 220, colour = NULL) {
  dot <- ""
  subtitle_colour <- "#303030"
  if (!is.null(colour)) {
    dot <- paste0(
      "<div style='width:14px; height:14px; border-radius:50%; flex-shrink:0; background:",
      colour,
      ";'></div>"
    )
    subtitle_colour <- colour
  }

  popup_container(
    width = width,
    "<div style='display:flex; align-items:center; gap:8px; margin-bottom:10px; padding-bottom:8px; border-bottom:2px solid #ddd;'>",
    dot,
    "<div style='flex:1;'>",
    "<div style='font-size:15px; font-weight:700; color:#222; line-height:1.2;'>",
    title,
    "</div>",
    "<div style='font-size:12px; font-weight:600; color:",
    subtitle_colour,
    "; letter-spacing:0.03em; margin-top:2px;'>",
    subtitle,
    "</div>",
    "</div>",
    "</div>",
    ...
  )
}

#' @rdname popup_card
#' @noRd
popup_container <- function(..., width = NULL) {
  width <- if (!is.null(width)) paste0(" width:", width, "px;") else ""
  paste0(
    "<div style='font-family:sans-serif; font-size:13px; max-height:320px; overflow-y:auto;",
    width,
    " padding-right:4px;'>",
    ...,
    "</div>"
  )
}

#' @rdname popup_card
#' @noRd
popup_row <- function(label, value) {
  paste0(
    "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
    "<span style='color:#888; min-width:100px;'>",
    label,
    "</span>",
    "<span style='font-weight:500; text-align:right;'>",
    value,
    "</span>",
    "</div>"
  )
}

#' @rdname popup_card
#' @noRd
popup_section <- function(...) {
  paste0(
    "<div style='margin-top:6px; padding-top:6px; border-top:1px solid #eee;'>",
    ...,
    "</div>"
  )
}
