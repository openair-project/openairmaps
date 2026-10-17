#' Automatic text formatting for `openairmaps`
#'
#' Workhorse function that automatically applies routine text formatting to
#' common pollutant names which may be used in the HTML widgets produced by
#' `openairmaps`.
#'
#' [quickTextHTML()] is routine formatting lookup table. It screens the supplied
#' character vector `text` and automatically applies formatting to any
#' recognised character sub-series to properly render in HTML.
#'
#' @param text *A character vector.*
#'
#'  **required**
#'
#'   A character vector containing common pollutant names to be formatted.
#'   Commonly, this will insert super- and subscript HTML tags, e.g., "NO2" will
#'   be replaced with "NO<sub>2</sub>".
#'
#' @export
#' @returns a character vector
#' @author Jack Davison.
#' @seealso [openair::quickText()], useful for non-HTML/static maps and plots
#'
#' @examples
#' labs <- c("no2", "o3", "so2")
#' quickTextHTML(labs)
#'
quickTextHTML <- function(text) {
  # whole words, ignoring case - applied in order
  words <- c(
    # meteo
    "wd" = "wind dir.",
    "ws" = "wind spd.",
    "temp" = "temperature",
    # gaseous
    "no2" = "NO<sub>2</sub>",
    "no" = "NO",
    "nox" = "NO<sub>x</sub>",
    "nh3" = "NH<sub>3</sub>",
    "co" = "CO",
    "nmhc" = "NMHC",
    "o3" = "O<sub>3</sub>",
    "co2" = "CO<sub>2</sub>",
    "so2" = "SO<sub>2</sub>",
    "h2s" = "H<sub>2</sub>S",
    "ch4" = "CH<sub>4</sub>",
    "nv10" = "NV<sub>10</sub>",
    "v10" = "V<sub>10</sub>",
    "nv25" = "NV<sub>2.5</sub>",
    "nv2.5" = "NV<sub>2.5</sub>",
    "v25" = "V<sub>2.5</sub>",
    "v2.5" = "V<sub>2.5</sub>",
    # particulates
    "pm25" = "PM<sub>2.5</sub>",
    "pm2.5" = "PM<sub>2.5</sub>",
    "pm10" = "PM<sub>10</sub>",
    "pm4" = "PM<sub>4</sub>",
    "pm1" = "PM<sub>1</sub>",
    "pmtot" = "PM<sub>total</sub>",
    "pmc" = "PM<sub>coarse</sub>",
    "pmcoarse" = "PM<sub>coarse</sub>",
    "pmf" = "PM<sub>fine</sub>",
    "pmfine" = "PM<sub>fine</sub>",
    "gr25" = "PM<sub>2.5</sub>&nbsp;(grav.)",
    "gr2.5" = "PM<sub>2.5</sub>&nbsp;(grav.)",
    "gr10" = "PM<sub>10</sub>&nbsp;(grav.)"
  )

  # anywhere, matching case - applied in order
  units <- c(
    "ug/m3" = "\u00B5g&nbsp;m<sup>-3</sup>",
    "ng/m3" = "ng&nbsp;m<sup>-3</sup>",
    "mg/m3" = "mg&nbsp;m<sup>-3</sup>",
    "m/s2" = "m&nbsp;s<sup>-2</sup>",
    "m/s" = "m&nbsp;s<sup>-1</sup>"
  )

  for (i in seq_along(words)) {
    pattern <- paste0("\\b", names(words)[[i]], "\\b")
    text <- gsub(pattern, words[[i]], text, ignore.case = TRUE)
  }
  for (i in seq_along(units)) {
    text <- gsub(names(units)[[i]], units[[i]], text)
  }

  text
}


#' Build a Complex Popup for a Leaflet Map
#'
#' Group a dataframe together by latitude/longitude columns and create a HTML
#' popup with user-defined columns. By default, the unique values of character
#' columns are collapsed into comma-separated lists, numeric columns are
#' averaged, and date columns are presented as a range. This function returns
#' the input dataframe appended with a "popup" column, which can then be used in
#' the `popup` argument of a function like [polarMap()].
#'
#' @inheritParams polarMap
#'
#' @param data *Input data table with geo-spatial information.*
#'
#'   **required**
#'
#'   A data frame containing latitude and longitude information that will go on
#'   to be used in a function such as [polarMap()].
#'
#' @param columns *A character vector of column names to include in the popup.*
#'
#'   **required**
#'
#'   Summaries of the selected columns will appear in the popup. If a named
#'   vector is provided, the names of the vector will be used in place of the
#'   raw column names. See the Examples for more information.
#'
#' @param type *A column to be passed to the `type` argument of another
#'   function.*
#'
#'  *default:* `NULL`
#'
#'   Column which will be used for the `type` argument of other mapping
#'   functions. This only needs to be used if `type` is going to be used in
#'   [polarMap()] or another similar function, and you'd expect different values
#'   for the different map layers (for example, if you are calculating a mean
#'   pollutant concentration).
#'
#' @param fun.character *A function to summarise character, factor and logical
#'   columns.*
#'
#'  *default:* `function(x) paste(unique(x), collapse = ", ")`
#'
#'   The default collapses unique values into a comma-separated list.
#'
#' @param fun.numeric *A function to summarise numeric columns.*
#'
#'  *default:* `function(x) signif(mean(x, na.rm = TRUE), 3)`
#'
#'   The default takes the mean to three significant figures. Other numeric
#'   summaries may be of interest, such as the maximum, minimum, standard
#'   deviation, and so on.
#'
#' @param fun.dttm *A function to summarise date and date-time columns.*
#'
#'  *default:* `function(x) paste(lubridate::floor_date(range(x, na.rm = TRUE), "day"), collapse = " to ")`
#'
#'   The default presents the date as a range. Other statistics of interest
#'   could be the start or end of the dates.
#'
#' @param ... **Not currently used.**
#'
#' @returns a [tibble][dplyr::tibble()]
#' @export
#'
#' @examples
#' \dontrun{
#' buildPopup(
#'   data = polar_data,
#'   columns = c(
#'     "Site" = "site",
#'     "Site Type" = "site_type",
#'     "Date Range" = "date"
#'   )
#' ) |>
#'   polarMap("nox", popup = "popup")
#' }
buildPopup <-
  function(
    data,
    columns,
    latitude = NULL,
    longitude = NULL,
    type = NULL,
    fun.character = function(x) {
      paste(unique(x), collapse = ", ")
    },
    fun.numeric = function(x) {
      signif(mean(x, na.rm = TRUE), 3)
    },
    fun.dttm = function(x) {
      paste(
        lubridate::floor_date(range(x, na.rm = TRUE), "day"),
        collapse = " to "
      )
    },
    ...
  ) {
    # assume latitude/longitude
    latlon <- assume_latlon(
      data = data,
      latitude = latitude,
      longitude = longitude
    )
    latitude <- latlon$latitude
    longitude <- latlon$longitude

    make_popup <- function(data) {
      # multiple columns
      summary <-
        data |>
        dplyr::select(dplyr::all_of(c(
          latitude,
          longitude,
          as.vector(columns)
        ))) |>
        dplyr::group_by(.data[[latitude]], .data[[longitude]]) |>
        dplyr::summarise(
          dplyr::across(
            dplyr::where(is.character) |
              dplyr::where(is.factor) |
              dplyr::where(is.logical),
            fun.character
          ),
          dplyr::across(dplyr::where(is.numeric), fun.numeric),
          dplyr::across(
            dplyr::where(lubridate::is.POSIXct) |
              dplyr::where(lubridate::is.Date),
            fun.dttm
          ),
          .groups = "drop"
        ) |>
        # keep the order of `columns`, not the order of the column types
        dplyr::select(dplyr::all_of(c(latitude, longitude, as.vector(columns))))

      if (!is.null(names(columns))) {
        names(columns)[names(columns) == ""] <- columns[names(columns) == ""]
        summary <- dplyr::rename(summary, dplyr::all_of(columns))
      }

      # one "<b>name</b>: value" row per column, combined into one popup
      values <- dplyr::select(summary, -dplyr::all_of(c(latitude, longitude)))
      rows <- Map(
        \(value, name) quickTextHTML(paste0("<b>", name, "</b>: ", value)),
        values,
        names(values)
      )
      summary$popup <- do.call(paste, c(unname(rows), sep = "<br>"))

      dplyr::left_join(
        data,
        summary[c(latitude, longitude, "popup")],
        by = c(latitude, longitude)
      )
    }

    if (!is.null(type)) {
      out <- dplyr::group_split(data, .data[[type]]) |>
        purrr::map(make_popup) |>
        purrr::list_rbind()
    } else {
      out <- make_popup(data)
    }

    out
  }

#' Convert a UK postcode to a latitude/longitude pair
#'
#' This is a much simpler implementation of the tools found in the
#' `PostcodesioR` R package, intended for use with the [networkMap()]
#' function.
#'
#' @param postcode *A valid UK postcode.*
#'
#'    **required**
#'
#'    A string containing a single valid UK postcode, e.g., `"SW1A 1AA"`.
#'
#' @returns A list containing the latitude, longitude, and input postcode.
#' @export
#' @examples
#' # convert a UK postcode
#' convertPostcode("SW1A1AA")
#'
#' \dontrun{
#' # use with `networkMap()`
#' palace <- convertPostcode("SW1A1AA")
#' networkMap("aurn", lat = palace$lat, lng = palace$lng, max_dist = 10)
#' }
#'
#' @seealso The `PostcodesioR` package at
#'   <https://github.com/ropensci/PostcodesioR/>
#' @source <https://postcodes.io/>
convertPostcode <- function(postcode) {
  rlang::check_installed(c("curl", "jsonlite"))
  response <- curl::curl_fetch_memory(fmt_api_call(postcode))

  if (response$status_code != 200L) {
    cli::cli_abort(raw_to_json(response$content)$error, call = NULL)
  }

  content <- raw_to_json(response$content)

  list(
    lat = content$result$latitude,
    lng = content$result$longitude,
    postcode = content$result$postcode
  )
}

#' @noRd
fmt_api_call <- function(postcode) {
  postcode <- tolower(postcode)
  postcode <- gsub(" ", "", postcode)
  paste0("api.postcodes.io/postcodes/", postcode)
}

#' @noRd
raw_to_json <- function(x) {
  jsonlite::fromJSON(rawToChar(x))
}
