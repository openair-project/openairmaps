#' Add trajectory paths to leaflet map
#'
#' This function is similar (but not identical to) the [leaflet::addMarkers()]
#' function in `leaflet`, which allows users to add trajectory paths to any
#' leaflet map and have more control over groups and layerIds than in
#' "all-in-one" functions like [trajMap()].
#'
#' @details [addTrajPaths()] can be a powerful way of quickly plotting
#'   trajectories on a leaflet map, but users should take some care due to any
#'   additional arguments being passed to both [leaflet::addCircleMarkers()] and
#'   [leaflet::addPolylines()]. In particular, users should be weary of the use
#'   of the `color` argument. Specifically, if `color` is passed a vector of
#'   length greater than one, multiple polylines will be drawn on top of one
#'   another. At best this will affect opacity, but at worst this will
#'   significantly impact the performance of R and the final leaflet map.
#'
#'   To mitigate this, please ensure that any vector passed to `color` is of
#'   length one. This is simple if you want the whole path to be the same
#'   colour, but more difficult if you want to colour by a pollutant, for
#'   example. The easiest way to achieve this is to write a for loop or use
#'   another iterative approach (e.g. the `purrr` package) to add one path per
#'   arrival date. An example of this is provided in the Examples.
#'
#'   If you only need to vary the colour of the *markers* rather than the
#'   lines - for example, colouring the points by a pollutant that changes
#'   over time - use `markerColor` instead, which is not subject to the same
#'   length-one restriction as `color` and can vary across every trajectory
#'   in `data`, not just within one. This often avoids the need for a loop
#'   entirely; see the Examples.
#'
#' @param map a map widget object created from [leaflet::leaflet()].
#' @param lng The decimal longitude.
#' @param lat The decimal latitude.
#' @param layerId The base string for the layer id. The actual layer IDs will be
#'   in the format "layerId-linenum" for lines and "layerId_linenum-pointnum"
#'   for points. For example, the first point of the first trajectory path will
#'   be "layerId-1-1".
#' @param group the name of the group the newly created layers should belong to
#'   (for [leaflet::clearGroup()] and [leaflet::addLayersControl()] purposes).
#'   Human-friendly group names are permitted–they need not be short,
#'   identifier-style names. Any number of layers and even different types of
#'   layers (e.g. markers and polygons) can share the same group name.
#' @param data Data frame, the result of importing a trajectory file using
#'   [openair::importTraj()]. By default, it is the data object provided to
#'   [leaflet::leaflet()] initially, but can be overridden.
#' @param npoints A dot is placed every `npoints` along each full trajectory.
#'   For hourly back trajectories points are plotted every `npoints` hours. This
#'   helps to understand where the air masses were at particular times and get a
#'   feel for the speed of the air (points closer together correspond to slower
#'   moving air masses). Defaults to `12`.
#' @param markerColor An optional colour (or vector of colours, one per row of
#'   `data`) to use for the point markers, overriding whatever `color` is
#'   passed via `...`. Unlike `color`/`fillColor`, this is permitted to vary
#'   per point - useful for colouring the markers along a single trajectory by
#'   a continuous variable (e.g. a pollutant) while keeping the trajectory
#'   line itself a single colour, as required by [leaflet::addPolylines()].
#' @param ... Other arguments o pass to both [leaflet::addCircleMarkers()] and
#'   [leaflet::addPolylines()]. If you use the `color` argument, it is important
#'   to ensure the vector you supply is of length one to avoid issues with
#'   [leaflet::addPolylines()] (i.e., use `color = ~ pal(nox)[1]`), unless you use
#'   `markerColor` to separately control the colour of the point markers. Note
#'   that `opacity` controls the opacity of the lines and `fillOpacity` the
#'   opacity of the markers.
#' @returns A leaflet object.
#' @seealso `shiny::runExample(package = "openairmaps")` to see examples of this
#'   function used in a [shiny::shinyApp()]
#' @export
#'
#' @examples
#' \dontrun{
#' library(leaflet)
#'
#' pal <- colorNumeric(palette = "viridis", domain = traj_data$height)
#'
#' map <- leaflet() |>
#'   addTiles()
#'
#' for (i in seq_along(unique(traj_data$date))) {
#'   data <- dplyr::filter(traj_data, date == unique(traj_data$date)[i])
#'
#'   map <- map |>
#'     addTrajPaths(
#'       data = data,
#'       color = pal(data$height)[1],
#'       markerColor = pal(data$height),
#'       opacity = 0.5,
#'       fillOpacity = 0.8
#'     )
#' }
#'
#' map
#' }
addTrajPaths <-
  function(
    map,
    lng = "lon",
    lat = "lat",
    layerId = NULL,
    group = NULL,
    data = leaflet::getMapData(map),
    npoints = 12,
    markerColor = NULL,
    ...
  ) {
    # check opts
    opts <- list(...)
    if ("color" %in% names(opts)) {
      if (length(opts$color) > 1) {
        cli::cli_abort("Length of 'color' argument greater than one.")
      }
    }
    if ("fillColor" %in% names(opts)) {
      if (length(opts$fillColor) > 1) {
        cli::cli_abort("Length of 'fillColor' argument greater than one.")
      }
    }

    # identify individual trajectories
    data$trajid <- traj_id(data)

    # attach per-row marker colours (if supplied) before any filtering, so
    # they are correctly subset alongside the rest of `data`
    if (!is.null(markerColor)) {
      data$markerColor <- markerColor
    }

    # labels (skip if the caller has already supplied one - e.g. trajMap()
    # adds a pollutant-specific line to the default label)
    if (!"lab" %in% names(data)) {
      data <- build_traj_labels(data)
    }

    for (i in seq_along(unique(data$trajid))) {
      if (!is.null(layerId)) {
        layerid <- paste(layerId, i, sep = "-")
      } else {
        layerid <- NULL
      }

      # get line/points data
      ldata <- dplyr::filter(data, .data$trajid == unique(data$trajid)[[i]])
      pdata <- dplyr::filter(ldata, .data$hour.inc %% npoints == 0)

      # add line to plot
      map <-
        leaflet::addPolylines(
          map = map,
          data = ldata,
          lng = ldata[[lng]],
          lat = ldata[[lat]],
          weight = 2,
          group = group,
          layerId = layerid,
          ...
        )

      # marker-specific colour overrides the line's colour, if supplied
      marker_opts <- opts
      if (!is.null(markerColor)) {
        marker_opts$color <- pdata$markerColor
      }

      # add all points in one vectorised call
      marker_arg <- append(
        list(
          map = map,
          data = pdata,
          radius = 3,
          stroke = FALSE,
          lng = pdata[[lng]],
          lat = pdata[[lat]],
          group = group,
          layerId = if (!is.null(layerid)) {
            sprintf("%s-%i", layerid, seq_len(nrow(pdata)))
          },
          popup = pdata[["lab"]]
        ),
        marker_opts
      )
      map <- rlang::exec(leaflet::addCircleMarkers, !!!marker_arg)
    }

    map
  }
