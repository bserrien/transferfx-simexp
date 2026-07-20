# design-simexp-gamma.R
# 
# design simulation experiments with gamma-distributed variables




# -------------------------------------------------------------------------
# gamma data, gamma noise -------------------------------------------------

# parameters of the scenario's:
# should match the arguments of the function sim_data_gamma()
#   sample_size
#   mu_x
#   cv_x
#   alpha
#   beta
#   cv_y
#   ratio_cvmex_cvx
#   ratio_mey_mex
#   corr_error

scenario_labeller_gamma <- function(df) {
  df %>% 
    mutate(
      sample_size_label     = paste0("Nsample", sample_size), 
      mu_x_label            = paste0("Mux", mu_x),
      cv_x_label            = paste0("CVx", cv_x),
      alpha_label           = paste0("Alpha", alpha),
      beta_label            = paste0("Beta", beta),
      cv_y_label            = paste0("CVy", cv_y),
      ratio_cvmex_cvx_label = paste0("Taux", ratio_cvmex_cvx),
      ratio_mey_mex_label   = paste0("Tauxy", ratio_mey_mex),
      corr_error_label      = paste0("Rho", corr_error)
    )
}


simexp_design5 <- expand_grid(
  sample_size     = c(100, 200, 500),
  mu_x            = 1,
  cv_x            = .5, 
  alpha           = 0,
  beta            = 1,
  cv_y            = c(0.01, 0.05, 0.10, 0.20),
  ratio_cvmex_cvx = 0.05,
  ratio_mey_mex   = 1,
  corr_error      = 0
) %>% scenario_labeller_gamma()


