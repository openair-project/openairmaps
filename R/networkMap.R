#' Create a leaflet map of air quality measurement network sites
#'
#' This function uses [openair::importMeta()] to obtain metadata for measurement
#' sites and uses it to create an interactive `leaflet` map. By default a map
#' will be created in which readers may toggle between a vector base map and a
#' satellite/aerial image, although users can further customise the control menu
#' using the `provider` and `control` parameters. Any argument which can be
#' passed to [openair::importMeta()] can be passed via `...`, with the exception
#' of `all` and `duplicate`.
#'
#' @param source *One or more UK or European monitoring networks.*
#'
#'    *default:* `"aurn"`
#'
#'   One or more air quality networks for which data is available through
#'   openair. Available networks include:
#'    - `"aurn"`, The UK Automatic Urban and Rural Network.
#'    - `"aqe"`, The Air Quality England Network.
#'    - `"saqn"`, The Scottish Air Quality Network.
#'    - `"waqn"`, The Welsh Air Quality Network.
#'    - `"ni"`, The Northern Ireland Air Quality Network.
#'    - `"local"`, Locally managed air quality networks in England.
#'    - `"imperial"`, Imperial College London (formerly King's College London) networks.
#'    - `"europe"`, European AirBase/e-reporting data.
#'
#'   There are two additional options provided for convenience:
#'    - `"ukaq"` will return metadata for all networks for which data is imported by importUKAQ() (i.e., AURN, AQE, SAQN, WAQN, NI, and the local networks).
#'    - `"all"` will import all available metadata (i.e., "ukaq" plus "kcl" and "europe").
#'
#' @inheritDotParams openair::importMeta -all -duplicate -source
#'
#' @param control *Option to create a 'layer control' menu.*
#'
#'  *default*: `NULL`
#'
#'   A string to specify categories in a "layer control" menu, to allow readers
#'   to select between different site categories. Choices include:
#'   - `"source"` to toggle between different networks
#'   - `"variable"` to toggle between different pollutants
#'   - `"site_type"` for different site classifications
#'   - `"agglomeration"`, `"zone"` or `"local_authority"` for different regions of the UK
#'
#' @param cluster *Cluster markers together when zoomed out?*
#'
#'  *default:* `NULL`
#'
#'   When `cluster = TRUE`, markers are clustered together. This may be useful
#'   for sources like `"imperial"` where there are many markers very close
#'   together. Defaults to `NULL`, which is `TRUE` if there are more than 25
#'   sites mapped and `FALSE` if there are fewer.
#'
#' @param provider *The basemap(s) to be used.*
#'
#'  *default:* `c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")`
#'
#'   Any number of [leaflet::providers]. See
#'   <http://leaflet-extras.github.io/leaflet-providers/preview/> for a list of
#'   all base maps that can be used. If multiple base maps are provided, they
#'   can be toggled between using a "layer control" interface. By default, the
#'   interface will use the provider names as labels, but users can define their
#'   own using a named vector (e.g., `c("Default" = "OpenStreetMap", "Satellite"
#'   = "Esri.WorldImagery")`)
#'
#' @param legend *Draw a shared legend?*
#'
#'  *default:* `TRUE`
#'
#'   When multiple `source`s are defined, should a shared legend be created at
#'   the side of the map?
#'
#' @param legend.position *Position of the legend*
#'
#'  *default:* `"topright"`
#'
#'   Where should the shared legend be placed? One of "topleft", "topright",
#'   "bottomleft" or "bottomright". Passed to the `position` argument of
#'   [leaflet::addLayersControl()].
#'
#' @param control.collapsed *Show the layer control as a collapsed?*
#'
#'  *default:* `FALSE`
#'
#'   Should the "layer control" interface be collapsed? If `TRUE`, users will
#'   have to hover over an icon to view the options.
#'
#' @param control.position *Position of the layer control menu*
#'
#'  *default:* `"topright"`
#'
#'   Where should the "layer control" interface be placed? One of "topleft",
#'   "topright", "bottomleft" or "bottomright". Passed to the `position`
#'   argument of [leaflet::addLayersControl()].
#'
#' @returns A leaflet object.
#' @export
#'
#' @order 1
#'
#' @examples
#' \dontrun{
#' # view one network, grouped by site type
#' networkMap(source = "aurn", control = "site_type")
#'
#' # view multiple networks, grouped by network
#' networkMap(source = c("aurn", "waqn", "saqn"), control = "network")
#' }
#'
networkMap <-
  function(
    source = "aurn",
    ...,
    control = NULL,
    cluster = NULL,
    provider = c(
      "Default" = "OpenStreetMap",
      "Satellite" = "Esri.WorldImagery"
    ),
    legend = TRUE,
    legend.position = "topright",
    control.collapsed = FALSE,
    control.position = "topright"
  ) {
    cols <-
      dplyr::tibble(
        source = c(
          "aurn",
          "saqn",
          "aqe",
          "waqn",
          "ni",
          "local",
          "imperial",
          "europe"
        ),
        colour = c(
          "red",
          "orange",
          "blue",
          "green",
          "purple",
          "lightgray",
          "black",
          "pink"
        ),
        realcolour = c(
          "#d33d29",
          "#f49630",
          "#36a5d7",
          "#70ad25",
          "#cf51b6",
          "#a3a3a3",
          "#303030",
          "#ff8ee9"
        )
      ) |>
      dplyr::mutate(
        colour2 = ifelse(.data$colour == "#FFFFFF", "#303030", "#FFFFFF")
      )

    # read in data
    meta <-
      openair::importMeta(
        source = source,
        ...,
        all = TRUE,
        duplicate = FALSE
      ) |>
      dplyr::left_join(cols, by = "source")

    # ensure consistency of columns
    for (i in c(
      "source",
      "code",
      "site",
      "site_type",
      "latitude",
      "longitude",
      "variable",
      "Parameter_name",
      "start_date",
      "end_date",
      "ratified_to",
      "zone",
      "agglomeration",
      "local_authority",
      "provider",
      "pcode",
      "distance_km"
    )) {
      if (!i %in% names(meta)) {
        meta[[i]] <- NA
      }
    }

    # resolve imperial
    if ("imperial" %in% c(meta$source)) {
      meta <-
        dplyr::mutate(
          meta,
          start_date = dplyr::coalesce(.data$start_date, .data$OpeningDate),
          end_date = dplyr::coalesce(.data$end_date, .data$ClosingDate),
          .keep = "unused"
        )
    }

    # prep for legend
    cols <- dplyr::filter(cols, .data$source %in% meta$source)

    # build maps
    # initialise map
    map <- leaflet::leaflet()

    # add provider tiles
    if (!rlang::is_named(provider)) {
      names(provider) <- provider
    }

    for (i in seq_along(provider)) {
      map <-
        leaflet::addProviderTiles(
          map,
          provider = provider[[i]],
          group = names(provider)[[i]]
        )
    }

    # if target specified, add to map
    dots <- rlang::list2(...)
    has_target <- "lat" %in% names(dots) && "lng" %in% names(dots)
    if (has_target) {
      target <- sf::st_as_sf(
        dplyr::tibble(lat = dots$lat, lng = dots$lng, crs = dots$crs %||% 4326),
        crs = dots$crs %||% 4326,
        coords = c("lng", "lat"),
        remove = FALSE
      ) |>
        sf::st_transform(crs = 4326)

      map <-
        map |>
        leaflet::addAwesomeMarkers(
          data = target,
          group = "Target",
          icon = leaflet::makeAwesomeIcon(
            library = "fa",
            icon = "search",
            markerColor = "white",
            iconColor = "black"
          ),
          popup = paste0(
            "<div style='font-family:sans-serif; font-size:13px; max-height:320px;
             overflow-y:auto; width:200px; padding-right:4px;'>",

            "<div style='display:flex; align-items:center; gap:8px; margin-bottom:10px;
               padding-bottom:8px; border-bottom:2px solid #ddd;'>",
            "<div style='width:14px; height:14px; border-radius:50%; flex-shrink:0; background:black;'></div>",
            "<div style='flex:1;'>",
            "<div style='font-size:15px; font-weight:700; color:#222; line-height:1.2;'>Search Location</div>",
            "<div style='font-size:12px; font-weight:600; color:#303030; letter-spacing:0.03em; margin-top:2px;'>TARGET</div>",
            "</div>",
            "</div>",

            "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
            "<span style='color:#888; min-width:100px;'>Latitude</span>",
            "<span style='font-weight:500; text-align:right;'>",
            target$lat,
            "</span>",
            "</div>",

            "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
            "<span style='color:#888; min-width:100px;'>Longitude</span>",
            "<span style='font-weight:500; text-align:right;'>",
            target$lng,
            "</span>",
            "</div>",

            "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
            "<span style='color:#888; min-width:100px;'>CRS</span>",
            "<span style='font-weight:500; text-align:right;'>EPSG:",
            target$crs,
            "</span>",
            "</div>",

            "</div>"
          )
        )

      if (!is.null(dots$max_dist)) {
        buffer <- sf::st_buffer(target, dist = dots$max_dist * 1000) |>
          sf::st_cast("MULTILINESTRING")

        map <- leaflet::addPolylines(
          map,
          data = buffer,
          weight = 1,
          color = "black",
          group = "Target"
        )
      }
    }

    # if there's no metadata, return the map now
    if (nrow(meta) == 0L) {
      return(leaflet::addLayersControl(
        map,
        position = control.position,
        options = leaflet::layersControlOptions(
          collapsed = control.collapsed,
          autoZIndex = FALSE
        ),
        baseGroups = names(provider)
      ))
    }

    # summarise into popups
    meta <- summarise_network_popup(meta, control = control)

    # sort out control
    if (!is.null(control)) {
      if (control == "variable") {
        names(meta)[names(meta) == "variable2"] <- "variable"
      }
      control.position <- check_legendposition(control.position, static = FALSE)
      control <- rlang::arg_match(
        control,
        names(meta)[
          !names(meta) %in%
            c(
              "var_date_block",
              "colour",
              "colour2",
              "realcolour",
              "popup_html",
              "variable2",
              "var_section_html",
              "overall_dates_html",
              "overall_end",
              "overall_start",
              "latitude",
              "longitude",
              "distance_km"
            )
        ]
      )

      # ensure "control" is always present, and that "other" category is at the end
      if (control != "source") {
        meta[[control]][is.na(meta[[control]])] <- "Other"
        meta[[control]] <- factor(meta[[control]])
        if ("Other" %in% levels(meta[[control]])) {
          cur_levels <- levels(meta[[control]])
          levels(meta[[control]]) <- c(
            cur_levels[cur_levels != "Other"],
            "Other"
          )
        }
      }
    } else {
      meta$control <- "Markers"
      control <- "control"
    }

    # cluster options
    if (
      cluster %||%
        any(purrr::map_vec(.x = split(meta, meta[[control]]), .f = \(x) {
          nrow(x) > 25
        }))
    ) {
      clusteropts <- leaflet::markerClusterOptions()
    } else {
      clusteropts <- NA
    }

    # get control variables
    control_vars <- sort(unique(meta[[control]]))

    # add markers
    for (i in seq_along(control_vars)) {
      dat <- dplyr::filter(meta, .data[[control]] == control_vars[[i]])

      map <- map |>
        leaflet::addAwesomeMarkers(
          data = dat,
          lat = dat[["latitude"]],
          lng = dat[["longitude"]],
          group = quickTextHTML(control_vars[[i]]),
          popup = dat[["popup_html"]],
          label = dat[["site"]],
          clusterOptions = clusteropts,
          icon = leaflet::makeAwesomeIcon(
            library = "fa",
            icon = "info-circle",
            markerColor = dat$colour,
            iconColor = dat$colour2
          )
        )
    }

    # add control menu
    control_vars <- sort(quickTextHTML(control_vars))
    if (has_target && control != "variable") {
      control_vars <- c(control_vars, "Target")
    }
    if ("Other" %in% control_vars) {
      control_vars <- c(control_vars[control_vars != "Other"], "Other")
    }
    if (control == "variable") {
      overlayGroups <- names(provider)
      baseGroups <- control_vars
    } else {
      baseGroups <- names(provider)
      overlayGroups <- control_vars
    }

    map <- leaflet::addLayersControl(
      map,
      position = control.position,
      options = leaflet::layersControlOptions(
        collapsed = control.collapsed,
        autoZIndex = FALSE
      ),
      baseGroups = baseGroups,
      overlayGroups = overlayGroups
    )

    # multiple sources - add legend
    if (dplyr::n_distinct(meta$source) > 1 && legend) {
      map <-
        leaflet::addLegend(
          map,
          opacity = 1,
          position = check_legendposition(legend.position, static = FALSE),
          title = "Network",
          colors = cols$realcolour,
          labels = paste0(
            "<span style='line-height:1.6'>",
            toupper(cols$source),
            "</span>"
          )
        )
    }

    # hide multiple basemaps
    if (length(provider) > 1) {
      map <- leaflet::hideGroup(map, names(provider)[-1])
    }

    map
  }

# collapse a metadata table into a nice popup
summarise_network_popup <- function(meta, control = NULL) {
  hc_vars <- c(
    "123TMB",
    "124TMB",
    "135TMB",
    "13BDIENE",
    "1BUTENE",
    "1PENTEN",
    "2MEPENT",
    "3MEPENT",
    "ACETALDEHYDE",
    "ACETONE",
    "BENZENE",
    "c2BUTENE",
    "c2PENTEN",
    "CYCLOPENTANE",
    "ETHANE",
    "ETHANOL",
    "ETHBENZ",
    "ETHENE",
    "ETHYNE",
    "iBUTANE",
    "iBUTENE",
    "iOCTANE",
    "iPENTANE",
    "ISOPRENE",
    "MEPENT",
    "mpXYLENE",
    "mXYLENE",
    "nBUTANE",
    "nHEPTANE",
    "nHEXANE",
    "nNONANE",
    "nOCTANE",
    "nPENTANE",
    "oXYLENE",
    "PROPANE",
    "PROPENE",
    "pXYLENE",
    "t2BUTENE",
    "t2PENTEN",
    "TOLUENE"
  )

  site_cols <- c(
    "source",
    "code",
    "site",
    "site_type",
    "latitude",
    "longitude",
    "zone",
    "agglomeration",
    "local_authority",
    "provider",
    "colour",
    "colour2",
    "realcolour",
    "distance_km"
  )

  meta <- meta |>
    dplyr::mutate(
      variable2 = dplyr::if_else(
        .data$variable %in% hc_vars,
        "HC",
        .data$variable
      ),
      var_date = dplyr::if_else(
        !is.na(.data$variable) & !is.na(.data$Parameter_name),
        paste0(
          "<div style='margin-bottom:6px; padding:5px 7px; background:#f5f5f5; border-radius:4px;'>",
          "<span style='font-weight:600;'>",
          quickTextHTML(.data$variable),
          "</span>",
          "<span style='color:#666; font-size:11px;'> (",
          .data$Parameter_name,
          ")</span><br>",
          "<span style='color:#888; font-size:11px;'>",
          "Start: ",
          format(.data$start_date, "%Y-%m-%d"),
          " &nbsp;|&nbsp; ",
          "End: ",
          ifelse(
            is.na(.data$end_date),
            "Ongoing",
            format(.data$end_date, "%Y-%m-%d")
          ),
          "</span>",
          "</div>"
        ),
        NA_character_
      )
    )

  # Always compute full per-site var_date_block and date range,
  # regardless of control - this goes into the popup
  site_summary <- meta |>
    dplyr::summarise(
      var_date_block = {
        valid <- .data$var_date[!is.na(.data$var_date)]
        if (length(valid) > 0) paste(valid, collapse = "") else NA_character_
      },
      overall_start = min(.data$start_date),
      overall_end = {
        non_missing <- .data$end_date[!is.na(.data$end_date)]
        if (length(non_missing) == 0) as.POSIXct(NA) else max(non_missing)
      },
      .by = dplyr::any_of(site_cols)
    )

  # If control = "variable", also summarise by site x variable2 to get
  # one row per marker, then join the full popup content back on
  if (!is.null(control) && control == "variable") {
    meta <- meta |>
      dplyr::distinct(dplyr::across(dplyr::any_of(c(
        site_cols,
        "variable2"
      )))) |>
      dplyr::left_join(site_summary, by = site_cols)
  } else {
    meta <- site_summary
  }

  # Build popup HTML
  meta |>
    dplyr::mutate(
      overall_dates_html = paste0(
        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Active from</span>",
        "<span style='font-weight:500; text-align:right;'>",
        format(.data$overall_start, "%Y-%m-%d"),
        "</span>",
        "</div>",
        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:10px;'>",
        "<span style='color:#888; min-width:100px;'>Active to</span>",
        "<span style='font-weight:500; text-align:right;'>",
        ifelse(
          is.na(.data$overall_end),
          "Ongoing",
          format(.data$overall_end, "%Y-%m-%d")
        ),
        "</span>",
        "</div>"
      ),
      var_section_html = dplyr::if_else(
        !is.na(.data$var_date_block),
        paste0(
          "<div style='font-size:12px; font-weight:700; color:#444;
                     margin-bottom:6px; padding-bottom:4px;
                     border-bottom:1px solid #ddd;'>Variables &amp; Measurement Periods</div>",
          .data$var_date_block
        ),
        ""
      ),
      popup_html = paste0(
        "<div style='font-family:sans-serif; font-size:13px; max-height:320px;
                   overflow-y:auto; width:290px; padding-right:4px;'>",

        "<div style='display:flex; align-items:center; gap:8px; margin-bottom:10px;
                     padding-bottom:8px; border-bottom:2px solid #ddd;'>",
        "<div style='width:14px; height:14px; border-radius:50%; flex-shrink:0; background:",
        .data$realcolour,
        ";'></div>",
        "<div style='flex:1;'>",
        "<div style='font-size:15px; font-weight:700; color:#222; line-height:1.2;'>",
        .data$site,
        "</div>",
        "<div style='font-size:12px; font-weight:600; color:",
        .data$realcolour,
        "; letter-spacing:0.03em; margin-top:2px;'>",
        paste(toupper(.data$source), "-", .data$code),
        "</div>",
        "</div>",
        "</div>",

        dplyr::if_else(
          !is.na(.data$distance_km),
          paste0(
            "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
            "<b><span style='color:black; min-width:100px;'>Distance from Target</span></b>",
            "<span style='font-weight:500; text-align:right;'><b>",
            signif(.data$distance_km, 4),
            " km",
            "</b></span>",
            "</div>"
          ),
          ""
        ),

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Site type</span>",
        "<span style='font-weight:500; text-align:right;'>",
        .data$site_type,
        "</span>",
        "</div>",

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Latitude</span>",
        "<span style='font-weight:500; text-align:right;'>",
        round(.data$latitude, 5),
        "</span>",
        "</div>",

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Longitude</span>",
        "<span style='font-weight:500; text-align:right;'>",
        round(.data$longitude, 5),
        "</span>",
        "</div>",

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Zone</span>",
        "<span style='font-weight:500; text-align:right;'>",
        ifelse(is.na(.data$zone), "-", .data$zone),
        "</span>",
        "</div>",

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Agglomeration</span>",
        "<span style='font-weight:500; text-align:right;'>",
        ifelse(is.na(.data$agglomeration), "-", .data$agglomeration),
        "</span>",
        "</div>",

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>Local authority</span>",
        "<span style='font-weight:500; text-align:right;'>",
        ifelse(is.na(.data$local_authority), "-", .data$local_authority),
        "</span>",
        "</div>",

        "<div style='display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:3px;'>",
        "<span style='color:#888; min-width:100px;'>LMAM Provider</span>",
        "<span style='font-weight:500; text-align:right;'>",
        ifelse(is.na(.data$provider), "-", .data$provider),
        "</span>",
        "</div>",

        .data$overall_dates_html,
        .data$var_section_html,

        "</div>"
      )
    )
}
