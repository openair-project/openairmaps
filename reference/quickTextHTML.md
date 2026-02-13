# Automatic text formatting for `openairmaps`

Workhorse function that automatically applies routine text formatting to
common pollutant names which may be used in the HTML widgets produced by
`openairmaps`.

## Usage

``` r
quickTextHTML(text)
```

## Arguments

- text:

  *A character vector.*

  **required**

  A character vector containing common pollutant names to be formatted.
  Commonly, this will insert super- and subscript HTML tags, e.g., "NO2"
  will be replaced with "NO₂".

## Value

a character vector

## Details

`quickTextHTML()` is routine formatting lookup table. It screens the
supplied character vector `text` and automatically applies formatting to
any recognised character sub-series to properly render in HTML.

## See also

[`openair::quickText()`](https://openair-project.github.io/openair/reference/quickText.html),
useful for non-HTML/static maps and plots

## Author

Jack Davison.

## Examples

``` r
labs <- c("no2", "o3", "so2")
quickTextHTML(labs)
#> [1] "NO<sub>2</sub>" "O<sub>3</sub>"  "SO<sub>2</sub>"
```
