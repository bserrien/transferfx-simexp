# simulate-data-gamma.R


#' sim_data_gamma
#' 
#' DGM for gamma-distributed soil variables (eg. ECEC). Structured as follows:
#' `x_true ~ Gamma(mean = mu_x, CV = cv_x)`
#' `mu_y   = exp(alpha + beta * log(x_true))`
#' `y_true ~ Gamma(mean = mu_y, CV = cv_y)`
#' `x_obs` = `x_true * eps_x`
#' `y_obs  = y_true * eps_y`
#' 
#' @param N sample size
#' @param mu_x mean of the predictor variable (= shape/rate)
#' @param cv_x coefficient of variation of the predictor variable (= 1 / sqrt(shape))
#' @param alpha intercept on log-scale
#' @param beta slope on log-scale
#' @param cv_y structural noise on log-scale
#' @param cv_mex CV of the multiplicative measurement error (x)
#' @param ratio_mey_mex ratio between the CV of the meas.err: cv_mey / cv_mex
#' @param corr_error correlation between x- and y- measurement errors
sim_data_gamma <- function(
    N             = 200,
    mu_x          = 5,      
    cv_x          = 0.4, 
    alpha         = 0,
    beta          = 1,
    cv_y          = 0.05,
    cv_mex        = 0.15,
    ratio_mey_mex = 1,
    corr_error    = 0
) {
  stopifnot("mu_x must be > 0 (x_true is Gamma-distributed)." = mu_x >= 0)
  
  # latent (true) predictor
  px     <- gamma_shape_rate(mu_x, cv_x)
  x_true <- rgamma(N, shape = px$shape, rate = px$rate)
  
  # latent (true) outcome: Gamma-GLM
  mu_y   <- exp(alpha + beta * log(x_true))
  py     <- gamma_shape_rate(mu_y, cv_y)
  y_true <- rgamma(N, shape = py$shape, rate = py$rate)
  
  # measurement error on x and y
  cv_mey <- cv_mex * ratio_mey_mex
  eta    <- rmult_error(N, cv_mex, cv_mey, corr_error, error_dist)
  x_obs  <- x_true * eta[, 1]
  y_obs  <- y_true * eta[, 2]
  
  out <- data.frame(x_true, x_obs, y_true, y_obs)
  return(out)
}


#' gamma_shape_rate
#' 
#' helper function: mean/CV -> shape/rate for a Gamma distribution
gamma_shape_rate <- function(mean, cv) {
  shape <- 1 / cv^2
  rate  <- shape / mean
  list(shape = shape, rate = rate)
}


#' rmult_error
#' 
#' helper function: multiplicative error with E[eps] = 1 (unbiased) and requested CV, (Gaussian-copula construction)
rmult_error <- function(N, cv, cv2, corr, shape_gamma = 40) {
  
  # Gaussian copula -> correlated uniforms -> gamma marginals, mean 1
  # bivariate standard-normal with correlation for use in copula's
  Sigma <- matrix(c(1, corr, corr, 1), 2, 2)
  Z     <- MASS::mvrnorm(N, mu = c(0, 0), Sigma = Sigma)
  U     <- pnorm(Z)
  eps1  <- qgamma(U[, 1], shape = shape_gamma, rate = shape_gamma)
  eps2  <- qgamma(U[, 2], shape = shape_gamma, rate = shape_gamma)
  eps   <- cbind(eps1, eps2)
  return(eps)
}

