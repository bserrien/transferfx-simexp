# simulate-data-gamma.R

# Structure:
# x_true ~ Gamma(mean = mu_x, CV = cv_x)
# x_obs  = x_true * eta_x  [error distribution eta_x = "lognormal" or "gamma"]
# mu_y   = exp(alpha + beta * log(x_true))  [log link]
# y_true ~ Gamma(mean = mu_y, CV = cv_y)
# y_obs  = y_true * eta_y  [error distribution eta_x = "lognormal" or "gamma"]

sim_data_gamma <- function(
    N            = 200,
    mu_x         = 5,      
    cv_x         = 0.4, 
    alpha        = 0,    # intercept on log-scale
    beta         = 1,    # slope on log-scale
    cv_y         = 0.05, # structural noise on log-scale
    cv_mex       = 0.15, # CV of the multiplicative measurement error
    ratio_mey_mex = 1, # ratio between the CV of the meas.err 
    error_dist   = c("lognormal", "gamma"),
    corr_error   = 0 # correlation between x- and y- measurement errors
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
rmult_error <- function(N, cv, cv2, corr, dist, shape_gamma = 4) {
  
  # bivariate standard-normal with correlation for use in copula's
  Sigma <- matrix(c(1, corr, corr, 1), 2, 2)
  Z <- MASS::mvrnorm(N, mu = c(0, 0), Sigma = Sigma)
  
  if (dist == "lognormal") {
    # sigma_log chosen so that Var(exp(eps)) matches the requested CV^2,
    # with mu_log set so E[eps] = 1 exactly
    sigma_log  <- sqrt(log(1 + cv^2))
    mu_log     <- -sigma_log^2 / 2
    eps1       <- exp(mu_log + sigma_log * Z[, 1])
    sigma_log2 <- sqrt(log(1 + cv2^2))
    mu_log2    <- -sigma_log2^2 / 2
    eps2       <- exp(mu_log2 + sigma_log2 * Z[, 2])
    eps        <- cbind(eps1, eps2)
  } else if (dist == "gamma") {
    # Gaussian copula -> correlated uniforms -> gamma marginals, mean 1
    U     <- pnorm(Z)
    rate1 <- shape_gamma
    eps1  <- qgamma(U[, 1], shape = shape_gamma, rate = rate1)
    eps2  <- qgamma(U[, 2], shape = shape_gamma, rate = shape_gamma)
    eps   <- cbind(eps1, eps2)
  }
  return(eps)
}



# Rationale for the error distribution choice:
#   The analysis model uses log(x_obs) as the predictor. A LOG-NORMAL
#   multiplicative error on x becomes NORMAL and ADDITIVE on the log scale:
#       log(x_obs) = log(x_true) + eps,   eps ~ N(0, sigma_log^2)
#   which matches the classical measurement-error assumption that SIMEX and
#   most correction methods are built on. A GAMMA multiplicative error stays
#   skewed on the log scale, so it's offered as a secondary option for
#   stress-testing robustness to non-normal error, not as the default.


