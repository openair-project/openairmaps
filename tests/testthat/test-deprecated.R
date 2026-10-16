test_that("deprecated static trajectory functions call openair", {
  withr::local_options(lifecycle_verbosity = "warning")
  traj <- small_traj(2)

  expect_warning(out <- trajLevelMapStatic(traj), "trajLevel")
  expect_s3_class(out, "ggplot")

  expect_warning(out <- trajMapStatic(traj), "trajPlot")
  expect_s3_class(out, "ggplot")
})
