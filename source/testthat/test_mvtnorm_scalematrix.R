library(mvtnorm)
library(testthat)

test_that("Covariance of rmvt with df=3 matches target varme when scaled by 1/3", {
  
  # Set seed for reproducibility
  set.seed(42)
  
  # 1. Define a target covariance matrix (equivalent to 'varme' in your script)
  # For example: variances of 2.0 and 1.0, with a covariance of 0.8
  varme_target <- matrix(
    c(2.0, 0.8, 
      0.8, 1.0), 
    nrow = 2, byrow = TRUE
  )
  
  # 2. Generate a very large number of samples to minimize sampling noise
  # Heavy tails (df=3) require a large N to stabilize the empirical covariance
  N <- 1000000 
  
  # 3. Generate data using the suggested correction: sigma = varme_target / 3
  samples <- mvtnorm::rmvt(N, sigma = varme_target / 3, df = 3)
  
  # 4. Calculate the empirical covariance of the generated samples
  empirical_cov <- cov(samples)
  
  # Print the matrices to the console for visual confirmation
  cat("\n--- TARGET COVARIANCE (varme) ---\n")
  print(varme_target)
  
  cat("\n--- EMPIRICAL COVARIANCE (N = 1,000,000) ---\n")
  print(empirical_cov)
  
  # 5. Assert that the empirical covariance matches the target covariance
  # We use a 5% tolerance due to the expected Monte Carlo variance of heavy-tailed distributions
  expect_equal(empirical_cov, varme_target, tolerance = 0.05)
})
