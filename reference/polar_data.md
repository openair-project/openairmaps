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
35040 rows and 14 columns.

## Source

`polar_data` was compiled from data using the
[`openair::importUKAQ()`](https://openair-project.github.io/openair/reference/importUKAQ.html)
function from the `openair` package with meteorological data from the
`worldmet` package.

## Details

- site,code:

  The site name and code. Useful for use with the `popup` and `label`
  arguments in `openairmaps` functions.

- date:

  The date and time of the measurement

- nox, no2, pm2.5, pm10:

  Pollutant concentrations

- wd:

  Wind direction, in degrees from North, as a numeric vector.

- ws:

  Wind speed, in m/s, as numeric vector.

- visibility:

  The visibility in metres.

- air_temp:

  Air temperature in degrees Celcius.

- latitude, longitude:

  Decimal latitude and longitude of the sites.

- site.type:

  Site type of the site (either "Urban Traffic" or "Urban Background").

## Examples

``` r
polar_data
#> # A tibble: 35,040 × 14
#>    site            code  date                  nox   no2 pm2.5  pm10    wd    ws
#>    <chr>           <chr> <dttm>              <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 London Bloomsb… CLL2  2009-01-01 00:00:00   113    46    42    46  58.9  2.07
#>  2 London Bloomsb… CLL2  2009-01-01 01:00:00    40    32    45    49  74.5  1.9 
#>  3 London Bloomsb… CLL2  2009-01-01 02:00:00    48    36    43    46  30    1.55
#>  4 London Bloomsb… CLL2  2009-01-01 03:00:00    36    29    37    NA  45    2.1 
#>  5 London Bloomsb… CLL2  2009-01-01 04:00:00    40    32    36    38  70    1.5 
#>  6 London Bloomsb… CLL2  2009-01-01 05:00:00    50    36    33    32  46.6  2.1 
#>  7 London Bloomsb… CLL2  2009-01-01 06:00:00    50    34    33    36  60    2.6 
#>  8 London Bloomsb… CLL2  2009-01-01 07:00:00    53    34    31    32  70    2.27
#>  9 London Bloomsb… CLL2  2009-01-01 08:00:00    80    50    27    30  54.5  2.35
#> 10 London Bloomsb… CLL2  2009-01-01 09:00:00   111    59    28    32  40    1.9 
#> # ℹ 35,030 more rows
#> # ℹ 5 more variables: visibility <dbl>, air_temp <dbl>, lat <dbl>, lon <dbl>,
#> #   site_type <chr>
```
