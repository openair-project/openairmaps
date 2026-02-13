# Convert a UK postcode to a latitude/longitude pair

This is a much simpler implementation of the tools found in the
`PostcodesioR` R package, intended for use with the
[`searchNetwork()`](https://openair-project.github.io/openairmaps/reference/searchNetwork.md)
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
# convert a UK postcode
convertPostcode("SW1A1AA")
#> $lat
#> [1] 51.50101
#> 
#> $lng
#> [1] -0.141563
#> 
#> $postcode
#> [1] "SW1A 1AA"
#> 

if (FALSE) { # \dontrun{
# use with `searchNetwork()`
palace <- convertPostcode("SW1A1AA")
searchNetwork(lat = palace$lat, lng = palace$lng, max_dist = 10)
} # }
```
