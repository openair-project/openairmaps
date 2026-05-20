# Trajectory plots in `ggplot2`

**\[deprecated\]**

These functions existed at a time when
[`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
and
[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)
were written in `lattice`. Now they are written in `ggplot2`, these
functions have been deprecated and now pass all of their arguments to
their corresponding
[openair](https://openair-project.github.io/openair/reference/openair-package.html)
functions. They will be removed in a future version of `openairmaps`.

## Usage

``` r
trajLevelMapStatic(...)

trajMapStatic(...)
```

## Arguments

- ...:

  Arguments passed to either
  [`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
  or
  [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html).
