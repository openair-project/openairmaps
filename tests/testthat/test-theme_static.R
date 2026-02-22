test_that("theme can be added to a ggplot2 object", {
  plot <- ggplot2::ggplot() + theme_static()
  expect_s3_class(plot, "ggplot")
})
