## SCRIPT TO IMPORT "polar_data"

# find meta data
site_meta <- openair::importMeta(source = "aurn") |>
  dplyr::filter(
    grepl(
      pattern = "Marylebone|Kensington|Bloom|Cromwell Road 2",
      site
    )
  )

# import aq data
raw <- openair::importUKAQ(
  site = site_meta$code,
  source = "aurn",
  year = 2009,
  meta = TRUE
) |>
  dplyr::select(
    site,
    code,
    date,
    nox,
    no2,
    pm2.5,
    pm10,
    lat = latitude,
    lon = longitude,
    site_type
  )

# import met data
met <- worldmet::importNOAA("037720-99999", year = 2009, source = "fwf") |>
  dplyr::select(date, wd, ws, visibility, air_temp)

# join
polar_data <- dplyr::left_join(raw, met, by = "date")

# rename
polar_data <- dplyr::relocate(polar_data, lat, lon, site_type, .after = 14)

# "save"
usethis::use_data(polar_data, overwrite = TRUE)
