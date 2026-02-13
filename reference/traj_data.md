# Example data for trajectory mapping functions

The `traj_data` dataset is provided as an example dataset as part of the
`openairmaps` package. The dataset contains HYSPLIT back trajectory data
for air mass parcels arriving in London in 2009. It has been joined with
air quality pollutant concentrations from the "London N. Kensington"
AURN urban background monitoring site.

## Usage

``` r
traj_data
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with
5432 rows and 17 columns.

## Source

`traj_data` was compiled from data using the
[`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html)
function from the `openair` package with air quality data from
[`openair::importAURN()`](https://openair-project.github.io/openair/reference/importUKAQ-wrapper.html)
function.

## Details

- date:

  The arrival time of the air-mass

- receptor:

  The receptor number

- year:

  Trajectory year

- month:

  Trajectory month

- day:

  Trajectory day

- hour:

  Trajectory hour

- hour.inc:

  Trajectory hour offset from the arrival date

- lat:

  Latitude

- lon:

  Longitude

- height:

  Height of trajectory in m

- pressure:

  Pressure of the trajectory in Pa

- date2:

  Date of the trajectory

- nox:

  Concentration of oxides of nitrogen (NO + NO2)

- no2:

  Concentration of nitrogen dioxide (NO2)

- o3:

  Concentration of ozone (O3)

- pm10:

  Concentration of particulates (PM10)

- pm2.5:

  Concentration of fine particulates (PM2.5)

## Examples

``` r
traj_data
#> # A tibble: 5,432 × 17
#>    date                receptor  year month   day  hour hour.inc   lat    lon
#>    <dttm>                 <int> <dbl> <int> <int> <int>    <dbl> <dbl>  <dbl>
#>  1 2010-04-15 00:00:00        1  2010     4    15     0        0  51.5 -0.1  
#>  2 2010-04-15 00:00:00        1  2010     4    14    23       -1  51.7  0.139
#>  3 2010-04-15 00:00:00        1  2010     4    14    22       -2  51.9  0.378
#>  4 2010-04-15 00:00:00        1  2010     4    14    21       -3  52.1  0.618
#>  5 2010-04-15 00:00:00        1  2010     4    14    20       -4  52.2  0.859
#>  6 2010-04-15 00:00:00        1  2010     4    14    19       -5  52.4  1.10 
#>  7 2010-04-15 00:00:00        1  2010     4    14    18       -6  52.6  1.34 
#>  8 2010-04-15 00:00:00        1  2010     4    14    17       -7  52.8  1.58 
#>  9 2010-04-15 00:00:00        1  2010     4    14    16       -8  53.0  1.82 
#> 10 2010-04-15 00:00:00        1  2010     4    14    15       -9  53.1  2.05 
#> # ℹ 5,422 more rows
#> # ℹ 8 more variables: height <dbl>, pressure <dbl>, date2 <dttm>, nox <dbl>,
#> #   no2 <dbl>, o3 <dbl>, pm2.5 <dbl>, pm10 <dbl>
```
