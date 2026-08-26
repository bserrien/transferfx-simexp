# Load required packages
library(testthat)
library(dplyr)
library(tidyr)
source("source/R/predictions.R")

test_that("Matrix implementation perfectly matches expand_grid implementation (Linear Regression)", {
  
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
  
  # Ignore dimension names/attributes
  expect_equal(
    unname(results_matrix$yhat), 
    unname(results_original$yhat)
  )
  
  expect_equal(
    unname(results_matrix$yhat_ll), 
    unname(results_original$yhat_ll)
  )
  
  expect_equal(
    unname(results_matrix$yhat_ul), 
    unname(results_original$yhat_ul)
  )
  # benchmark_results <- bench::mark(
  #   expand_grid_method = withr::with_seed(
  #     seed = 2026, predx_linreg(mock_draws, mock_newdata)
  #   ),
  #   matrix_method = withr::with_seed(
  #     seed = 2026,
  #     predx_linreg_matrix(mock_draws, mock_newdata)[, 1:6]),
  #   iterations = 10,
  #   memory = TRUE
  # )
  # 
  # benchmark_results
})

test_that("Matrix implementation perfectly matches expand_grid implementation (EIV Unknown SD)", {
  
  D <- 4000
  N <- 1000
  
  # Simulate draws with required EIV parameters
  mock_draws_eiv <- data.frame(
    b_Intercept = rnorm(D, 0, 1),
    b_x_obs     = rnorm(D, 1, 0.5),
    inv_var_x   = runif(D, 0.5, 2.0),
    mu_x        = rnorm(D, 5, 1),
    inv_var_mex = runif(D, 1.0, 4.0),
    sd_yobs     = rlnorm(D, 0, 0.5)
  ) %>%
    mutate(tilde_v = 1.0 / (inv_var_x + inv_var_mex))
  
  mock_newdata <- data.frame(
    uniqueid = 1:N,
    x_obs    = rnorm(N, 5, 2),
    y_true   = rnorm(N, 5, 2),
    y_obs    = rnorm(N, 5, 2.5)
  )
  
  set.seed(2026)
  results_original <- predx_eivreg(mock_draws_eiv, mock_newdata)
  
  set.seed(2026)
  results_matrix <- predx_eivreg_matrix(mock_draws_eiv, mock_newdata)
  
  expect_equal(unname(results_matrix$yhat), unname(results_original$yhat))
  expect_equal(unname(results_matrix$yhat_ll), unname(results_original$yhat_ll))
  expect_equal(unname(results_matrix$yhat_ul), unname(results_original$yhat_ul))
  # benchmark_results <- bench::mark(
  #   expand_grid_method = withr::with_seed(
  #     seed = 2026, predx_eivreg(mock_draws_eiv, mock_newdata)
  #   ),
  #   matrix_method = withr::with_seed(
  #     seed = 2026,
  #     predx_eivreg_matrix(mock_draws_eiv, mock_newdata)[, 1:6]),
  #   iterations = 10,
  #   memory = TRUE
  # )
  # 
  # benchmark_results
})


test_that("Matrix implementation perfectly matches expand_grid implementation (EIV Known SD)", {
  
  D <- 4000
  N <- 1000
  
  # Simulate draws with required EIV known SD parameters
  mock_draws_eiv_knownsd <- data.frame(
    b_Intercept = rnorm(D, 0, 1),
    b_x_obs     = rnorm(D, 1, 0.5),
    inv_var_x   = runif(D, 0.5, 2.0),
    mu_x        = rnorm(D, 5, 1),
    sigma       = rlnorm(D, 0, 0.5)
  )
  
  mock_newdata <- data.frame(
    uniqueid = 1:N,
    x_obs    = rnorm(N, 5, 2),
    y_true   = rnorm(N, 5, 2),
    y_obs    = rnorm(N, 5, 2.5)
  )
  
  # scalar representation of the known standard deviation of measurement error
  mock_newdatasd <- 0.5
  
  set.seed(2026)
  results_original <- predx_eivreg_knownsd(
    mock_draws_eiv_knownsd, mock_newdata, mock_newdatasd
  )
  
  set.seed(2026)
  results_matrix <- predx_eivreg_knownsd_matrix(
    mock_draws_eiv_knownsd, mock_newdata, mock_newdatasd
  )
  
  expect_equal(unname(results_matrix$yhat), unname(results_original$yhat))
  expect_equal(unname(results_matrix$yhat_ll), unname(results_original$yhat_ll))
  expect_equal(unname(results_matrix$yhat_ul), unname(results_original$yhat_ul))
  # benchmark_results <- bench::mark(
  #   expand_grid_method = withr::with_seed(
  #     seed = 2026, predx_eivreg_knownsd(
  #       mock_draws_eiv_knownsd, mock_newdata, mock_newdatasd
  #     )
  #   ),
  #   matrix_method = withr::with_seed(
  #     seed = 2026,
  #     predx_eivreg_knownsd_matrix(
  #       mock_draws_eiv_knownsd, mock_newdata, mock_newdatasd
  #     )[, 1:6]),
  #   iterations = 10,
  #   memory = TRUE
  # )
  # 
  # benchmark_results
})
