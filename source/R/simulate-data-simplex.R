# simulate-data-simplex

# simulate data for TF of simplex data: clay + silt + sand = 1

sim_data_simplex <- function(
  N         = 100,
  mu_ilr    = c(.5, .25),
  cov_ilr   = matrix(c(.16, -.14, -.14, 1.34), byrow = T, nrow = 2),
  alpha_ilr = 0,  # assume same alpha for both ILR components
  beta_ilr  = 1,  # assume same beta for both ILR components
  sigma_ilr = .1, # assume same sigma for both ILR components
  sd_mex    = .1, # assume same measurement error on both ILR components
  ratio_sdmey_sdmex = 1,
  corr_mexy         = 0
) {
  
  # simulate latent values for the non-reference method (ILR-scale)
  ilr_x <- MASS::mvrnorm(N, mu_ilr, cov_ilr)
  
  # regression to latent values of the reference method (ILR-scale)
  ilr_y <- alpha_ilr + beta_ilr * ilr_x +
    matrix(rnorm(N * 2, 0, sigma_ilr), nrow = N, ncol = 2)
  
  # transform latent ILR to PSD (%)
  psd_x <- data.frame(compositions::ilrInv(ilr_x))
  colnames(psd_x) <- c("x_true_clay","x_true_silt","x_true_sand")
  psd_y <- data.frame(compositions::ilrInv(ilr_y))
  colnames(psd_y) <- c("y_true_clay","y_true_silt","y_true_sand")
  psd <- cbind(psd_x, psd_y)
  
  # add measurement noise: additive noise on ILR-scale
  sd_mey <- sd_mex * ratio_sdmey_sdmex
  eps_xy <- MASS::mvrnorm(
    n     = N, 
    mu    = rep(0, 4), 
    Sigma = matrix(
      c(sd_mex^2, 0, corr_mexy * sd_mex * sd_mey, 0,
        0, sd_mex^2, 0, corr_mexy * sd_mex * sd_mey,
        corr_mexy * sd_mex * sd_mey, 0, sd_mey^2, 0,
        0, corr_mexy * sd_mex * sd_mey, 0, sd_mey^2), 
      byrow = T, nrow = 4
    )
  )
  ilr_x_obs <- ilr_x + eps_xy[, 1:2]
  ilr_y_obs <- ilr_y + eps_xy[, 3:4]
  
  # transform observed to PSD (%)
  psd_x_obs <- data.frame(compositions::ilrInv(ilr_x_obs))
  colnames(psd_x_obs) <- c("x_obs_clay","x_obs_silt","x_obs_sand")
  psd_y_obs <- data.frame(compositions::ilrInv(ilr_y_obs))
  colnames(psd_y_obs) <- c("y_obs_clay","y_obs_silt","y_obs_sand")
  psd_obs <- cbind(psd_x_obs, psd_y_obs)
  
  #####
  # same procedure for validation data
  N_new     <- 1000
  ilr_x_new <- MASS::mvrnorm(N_new, mu_ilr, cov_ilr)
  ilr_y_new <- alpha_ilr + beta_ilr * ilr_x_new +
    matrix(rnorm(N_new * 2, 0, sigma_ilr), nrow = N_new, ncol = 2)
  psd_x_new           <- data.frame(compositions::ilrInv(ilr_x_new))
  colnames(psd_x_new) <- c("x_true_clay","x_true_silt","x_true_sand")
  psd_y_new           <- data.frame(compositions::ilrInv(ilr_y_new))
  colnames(psd_y_new) <- c("y_true_clay","y_true_silt","y_true_sand")
  psd_new             <- cbind(psd_x_new, psd_y_new)
  eps_xy_new <- MASS::mvrnorm(
    n     = N_new, 
    mu    = rep(0, 4), 
    Sigma = matrix(
      c(sd_mex^2, 0, corr_mexy * sd_mex * sd_mey, 0,
        0, sd_mex^2, 0, corr_mexy * sd_mex * sd_mey,
        corr_mexy * sd_mex * sd_mey, 0, sd_mey^2, 0,
        0, corr_mexy * sd_mex * sd_mey, 0, sd_mey^2), 
      byrow = T, nrow = 4
    )
  )
  ilr_x_obs_new <- ilr_x_new + eps_xy_new[, 1:2]
  ilr_y_obs_new <- ilr_y_new + eps_xy_new[, 3:4]
  psd_x_obs_new           <- data.frame(compositions::ilrInv(ilr_x_obs_new))
  colnames(psd_x_obs_new) <- c("x_obs_clay","x_obs_silt","x_obs_sand")
  psd_y_obs_new           <- data.frame(compositions::ilrInv(ilr_y_obs_new))
  colnames(psd_y_obs_new) <- c("y_obs_clay","y_obs_silt","y_obs_sand")
  psd_obs_new             <- cbind(psd_x_obs_new, psd_y_obs_new)
  
  # output for use in STAN models
  # not each element in the list is necessary for each model, stan will ignore
  # unused elements by default
  df_stan <- list(
    K = 3, # 3-dimensional simplex
    
    #### calibration data
    N = N, 
    
    # mv-linreg model on ILR-scale
    ilr_x_obs = ilr_x_obs, # predictor variables
    ilr_y_obs = ilr_y_obs, # outcome variables
    
    # for mv-linreg with known covariance of the measurement error
    Sigma_mex = diag(rep(sd_mex^2, 2)),
    
    # Dirichlet model on simplex
    psd_x_obs = psd_x_obs, # predictor variables
    psd_y_obs = psd_y_obs, # outcome variables
    
    #### validation data
    N_new         = N_new,
    ilr_x_obs_new = ilr_x_obs_new,
    psd_new       = cbind(id = 1:N_new, psd_new, psd_obs_new)
  )
  return(df_stan)
}


