# Example data for polar mapping functions

The `polar_data` dataset is provided as an example dataset as part of
the `openairmaps` package. The dataset contains hourly measurements of
air pollutant concentrations, location and meteorological data.

## Usage

``` r
polar_data
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with
35040 rows and 13 columns.

## Source

`polar_data` was compiled from data using the
[`openair::importAURN()`](https://openair-project.github.io/openair/reference/importUKAQ-wrapper.html)
function from the `openair` package with meteorological data from the
`worldmet` package.

## Details

- date:

  The date and time of the measurement

- nox, no2, pm2.5, pm10:

  Pollutant concentrations

- site:

  The site name. Useful for use with the `popup` and `label` arguments
  in `openairmaps` functions.

- latitude, longitude:

  Decimal latitude and longitude of the sites.

- site.type:

  Site type of the site (either "Urban Traffic" or "Urban Background").

- wd:

  Wind direction, in degrees from North, as a numeric vector.

- ws:

  Wind speed, in m/s, as numeric vector.

- visibility:

  The visibility in metres.

- air_temp:

  Air temperature in degrees Celcius.

## Examples

``` r
polar_data
#> # A tibble: 35,040 × 13
#>    date                  nox   no2 pm2.5  pm10 site         lat    lon site_type
#>    <dttm>              <dbl> <dbl> <dbl> <dbl> <chr>      <dbl>  <dbl> <chr>    
#>  1 2009-01-01 00:00:00   113    46    42    46 London Bl…  51.5 -0.126 Urban Ba…
#>  2 2009-01-01 01:00:00    40    32    45    49 London Bl…  51.5 -0.126 Urban Ba…
#>  3 2009-01-01 02:00:00    48    36    43    46 London Bl…  51.5 -0.126 Urban Ba…
#>  4 2009-01-01 03:00:00    36    29    37    NA London Bl…  51.5 -0.126 Urban Ba…
#>  5 2009-01-01 04:00:00    40    32    36    38 London Bl…  51.5 -0.126 Urban Ba…
#>  6 2009-01-01 05:00:00    50    36    33    32 London Bl…  51.5 -0.126 Urban Ba…
#>  7 2009-01-01 06:00:00    50    34    33    36 London Bl…  51.5 -0.126 Urban Ba…
#>  8 2009-01-01 07:00:00    53    34    31    32 London Bl…  51.5 -0.126 Urban Ba…
#>  9 2009-01-01 08:00:00    80    50    27    30 London Bl…  51.5 -0.126 Urban Ba…
#> 10 2009-01-01 09:00:00   111    59    28    32 London Bl…  51.5 -0.126 Urban Ba…
#> # ℹ 35,030 more rows
#> # ℹ 4 more variables: wd <dbl>, ws <dbl>, visibility <dbl>, air_temp <dbl>
```
