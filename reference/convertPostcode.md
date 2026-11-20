# Convert a UK postcode to a latitude/longitude pair

This is a much simpler implementation of the tools found in the
`PostcodesioR` R package, intended for use with the
[`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
function.

## Usage

``` r
convertPostcode(postcode)
```

## Source

<https://postcodes.io/>

## Arguments

- postcode:

  *A valid UK postcode.*

  **required**

  A string containing a single valid UK postcode, e.g., `"SW1A 1AA"`.

## Value

A list containing the latitude, longitude, and input postcode.

## See also

The `PostcodesioR` package at
<https://github.com/ropensci/PostcodesioR/>

## Examples

``` r
rlang::is_installed(c("curl", "jsonlite"))
#> [1] TRUE
if (FALSE) { # \dontrun{
# convert a UK postcode (needs an internet connection)
convertPostcode("SW1A1AA")

# use with `networkMap()`
palace <- convertPostcode("SW1A1AA")
networkMap("aurn", lat = palace$lat, lng = palace$lng, max_dist = 10)
} # }
```
