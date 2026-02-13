# Build a Complex Popup for a Leaflet Map

Group a dataframe together by latitude/longitude columns and create a
HTML popup with user-defined columns. By default, the unique values of
character columns are collapsed into comma-separated lists, numeric
columns are averaged, and date columns are presented as a range. This
function returns the input dataframe appended with a "popup" column,
which can then be used in the `popup` argument of a function like
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).

## Usage

``` r
buildPopup(
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
     paste(lubridate::floor_date(range(x, na.rm = TRUE),
    "day"), collapse = " to ")
 },
  ...
)
```

## Arguments

- data:

  *Input data table with geo-spatial information.*

  **required**

  A data frame containing latitude and longitude information that will
  go on to be used in a function such as
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).

- columns:

  *A character vector of column names to include in the popup.*

  **required**

  Summaries of the selected columns will appear in the popup. If a named
  vector is provided, the names of the vector will be used in place of
  the raw column names. See the Examples for more information.

- latitude, longitude:

  *The decimal latitude(Y)/longitude(X).*

  *default:* `NULL` \| *scope:* dynamic & static

  Column names representing the decimal latitude and longitude (or other
  Y/X coordinate if using a different `crs`). If not provided, will be
  automatically inferred from data by looking for a column named
  "lat"/"latitude" or "lon"/"lng"/"long"/"longitude"
  (case-insensitively).

- type:

  *A column to be passed to the `type` argument of another function.*

  *default:* `NULL`

  Column which will be used for the `type` argument of other mapping
  functions. This only needs to be used if `type` is going to be used in
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  or another similar function, and you'd expect different values for the
  different map layers (for example, if you are calculating a mean
  pollutant concentration).

- fun.character:

  *A function to summarise character and factor columns.*

  *default:* `function(x) paste(unique(x), collapse = ", ")`

  The default collapses unique values into a comma-separated list.

- fun.numeric:

  *A function to summarise numeric columns.*

  *default:* `function(x) signif(mean(x, na.rm = TRUE), 3)`

  The default takes the mean to three significant figures. Other numeric
  summaries may be of interest, such as the maximum, minimum, standard
  deviation, and so on.

- fun.dttm:

  *A function to summarise date columns.*

  *default:*
  `function(x) paste(lubridate::floor_date(range(x, na.rm = TRUE), "day"), collapse = " to ")`

  The default presents the date as a range. Other statistics of interest
  could be the start or end of the dates.

- ...:

  **Not currently used.**

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble.html)

## Examples

``` r
if (FALSE) { # \dontrun{
buildPopup(
  data = polar_data,
  columns = c(
    "Site" = "site",
    "Site Type" = "site_type",
    "Date Range" = "date"
  )
) |>
  polarMap("nox", popup = "popup")
} # }
```
