# design-simexp-simplex.R
# 
# design simulation experiments with 3d-simplex-distributed variables
# clay + silt + sand = 1



# -------------------------------------------------------------------------

# parameters of the scenario's:
# should match the arguments of the function sim_data_simplex()
#   N
#   mu_ilr
#   cov_ilr
#   alpha_ilr 
#   beta_ilr
#   sigma_ilr
#   sd_mex
#   ratio_sdmey_sdmex
#   corr_mexy


scenario_labeller_simplex <- function(df) {
  df %>% 
    mutate(
      # for the moment we don't use these parameters in the scenario's
      # all scenario's have the same Mu/Sigma
      # mu_ilr_label  = paste0("MuIlr", mu_ilr[1]),
      # cov_ilr_label = paste0("CovIlr", cov_ilr[1,1]),
      sample_size_label       = paste0("Nsample", N), 
      alpha_ilr_label         = paste0("AlphaIlr", alpha_ilr),
      beta_ilr_label          = paste0("BetaIlr", beta_ilr),
      sigma_ilr_label         = paste0("SigmaIlr", sigma_ilr),
      sd_mex_label            = paste0("SDmex", sd_mex),
      ratio_sdmey_sdmex_label = paste0("RatioSDme", ratio_sdmey_sdmex),
      corr_mexy_label         = paste0("CorrMe", corr_mexy)
    )
}



# experimental parameters for simexp9: sample_size & sigma_ilr
simexp_design9 <- expand_grid(
  N         = c(100, 200, 500),
  mu_ilr    = vector(mode = "list", length = 1),
  cov_ilr   = vector(mode = "list", length = 1),
  alpha_ilr = 0, 
  beta_ilr  = 1,  
  sigma_ilr = c(.01, .1, .5),
  sd_mex    = .1, 
  ratio_sdmey_sdmex = 1,
  corr_mexy         = 0
) %>% scenario_labeller_simplex()

simexp_design9$mu_ilr  <- list(matrix(c(.5, .25), nrow = 2))
simexp_design9$cov_ilr <- list(matrix(c(.16, -.14, -.14, 1.34), 
                                      byrow = T, nrow = 2))


