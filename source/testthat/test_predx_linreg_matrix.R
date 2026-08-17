# Load required packages
library(testthat)
library(dplyr)
library(tidyr)
source("source/R/predictions.R")

test_that("Matrix implementation perfectly matches expand_grid implementation", {
  
  # Simulate 4000 posterior draws
  D <- 4000
  mock_draws <- data.frame(
    b_Intercept = rnorm(D, 0, 1),
    b_x_obs     = rnorm(D, 1, 0.5),
    sigma       = rlnorm(D, 0, 0.5)
  )
  
  # Simulate 1000 validation observations
  N <- 1000
  mock_newdata <- data.frame(
    uniqueid = 1:N,
    x_obs    = rnorm(N, 5, 2),
    y_true   = rnorm(N, 5, 2),
    y_obs    = rnorm(N, 5, 2.5)
  )
  
  # Run the original function, setting the seed immediately prior
  set.seed(2026)
  results_original <- predx_linreg(mock_draws, mock_newdata)
  
  # Run the matrix function, setting the exact same seed immediately prior
  set.seed(2026)
  results_matrix <- predx_linreg_matrix(mock_draws, mock_newdata)
  
  # Ignore dimension names/attributes that apply() might append differently than summarise()
  expect_equal(
    results_matrix$yhat, 
    results_original$yhat, 
    ignore_attr = TRUE
  )
  
  expect_equal(
    results_matrix$yhat_ll, 
    results_original$yhat_ll, 
    ignore_attr = TRUE
  )
  
  expect_equal(
    results_matrix$yhat_ul, 
    results_original$yhat_ul, 
    ignore_attr = TRUE
  )
  
  # benchmark_results <- bench::mark(
  #   expand_grid_method = withr::with_seed(
  #     seed = 2026, predx_linreg(mock_draws, mock_newdata)
  #   ),
  #   matrix_method = withr::with_seed(
  #     seed = 2026,
  #     predx_linreg_matrix(mock_draws, mock_newdata)),
  #   iterations = 10,
  #   memory = TRUE
  # )
  # 
  # benchmark_results
})


