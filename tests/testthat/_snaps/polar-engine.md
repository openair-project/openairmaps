# polar_map_init() errors for removed `control`/`facet`

    Code
      fake_map_fun(data, control = "site")
    Condition
      Error in `fake_map_fun()`:
      x `control` has been removed.
      i Please use `type` instead.

---

    Code
      fake_map_fun(data, control = "site", facet = "site")
    Condition
      Error in `fake_map_fun()`:
      x `control` and `facet` have been removed.
      i Please use `type` instead.

