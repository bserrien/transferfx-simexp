
# sim_data
sim_data <- function(
    N = 200,
    mu_x = 1,
    sigma_x = 1,
    alpha = 0,
    beta = 1
) {
  
  # latent predictor
  x_true <- rlnorm(N, mu_x, sigma_x)
  # latent outcome
  y_true <- (alpha + beta * x_true) * rgamma(N, 1/0.05, 1/0.05)
  
  # observed predictor & outcome: add multiplicative measurement error
  # sdmex <- ratio_sdmex_sigmax * sigma_x
  # sdmey <- ratio_sdmey_sdmex * sdmex
  # varme <- matrix(
  #   c(sdmex^2, rep(sdmex * sdmey * corr_sdmey_sdmex, 2), sdmey^2),
  #   byrow = TRUE, nrow = 2
  # )
  # xy_obs <- switch(
  #   tails,
  #   normal = c(x_true, y_true) + MASS::mvrnorm(N, c(0, 0), varme),
  #   tdf3   = c(x_true, y_true) + mvtnorm::rmvt(N, 1/3*sqrt(varme), df = 3)
  #   # see the help file of mvtnorm::rmvt for why the 1/3 scaler is added
  # )
  
  # list for STAN models
  df_stan <- list( 
    N         = N, 
    y_obs     = xy_obs[,2],
    x_obs     = xy_obs[,1],
    sigma_mex = sdmex # only for use in model with known SD of meas.err
  )
}
