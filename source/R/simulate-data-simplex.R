# simulate-data-simplex

# simulate data for TF of simplex data: clay + silt + sand = 1

sim_data_simplex <- function(
  N         = 100,
  mu_ilr    = c(.5, .25),
  cov_ilr   = matrix(c(.16, -.14, -.14, 1.34), byrow = T, nrow = 2),
  alpha_ilr = c(.2, .5),
  beta_ilr  = c(.9, 1.2),
  sigma_ilr = c(.1, .1),
  sd_mex1   = .1,
  sd_mex2   = .1,
  ratio_sdmey_sdmex = 1,
  corr_mexy         = 0
) {
  
  # simulate latent values for the non-reference method
  ilr_x <- data.frame(MASS::mvrnorm(N, mu_ilr, cov_ilr))

  # regression to latent values of the reference method
  ilr_y <- data.frame(
    Y1 = rnorm(N, alpha_ilr[1] + beta_ilr[1] * ilr_x$X1, sigma_ilr[1]),
    Y2 = rnorm(N, alpha_ilr[2] + beta_ilr[2] * ilr_x$X2, sigma_ilr[2])
  )
  
  # transform latent to PSD (%)
  psd_x <- data.frame(compositions::ilrInv(ilr_x))
  colnames(psd_x) <- c("x_true_clay","x_true_silt","x_true_sand")
  psd_y <- data.frame(compositions::ilrInv(ilr_y))
  colnames(psd_y) <- c("y_true_clay","y_true_silt","y_true_sand")
  psd <- cbind(psd_x, psd_y)
  
  # add measurement noise: additive noise on ILR-scale
  sd_mey1 <- sd_mex1 * ratio_sdmey_sdmex
  sd_mey2 <- sd_mex2 * ratio_sdmey_sdmex
  eps_xy <- MASS::mvrnorm(
    n     = N, 
    mu    = rep(0, 4), 
    Sigma = matrix(
      c(sd_mex1^2, 0, corr_mexy * sd_mex1 * sd_mey1, 0,
        0, sd_mex2^2, 0, corr_mexy * sd_mex2 * sd_mey2,
        corr_mexy * sd_mex1 * sd_mey1, 0, sd_mey1^2, 0,
        0, corr_mexy * sd_mex2 * sd_mey2, 0, sd_mey2^2), 
      byrow = T, nrow = 4
    )
  )
  ilr_x_obs <- ilr_x + eps_xy[, 1:2]
  ilr_x_obs <- mutate(ilr_x_obs, X0 = 1, .before = X1) # intercept
  ilr_y_obs <- ilr_y + eps_xy[, 3:4]
  
  # transform observed to PSD (%)
  psd_x_obs <- data.frame(compositions::ilrInv(ilr_x_obs[, 2:3]))
  colnames(psd_x_obs) <- c("x_obs_clay","x_obs_silt","x_obs_sand")
  psd_y_obs <- data.frame(compositions::ilrInv(ilr_y_obs))
  colnames(psd_y_obs) <- c("y_obs_clay","y_obs_silt","y_obs_sand")
  psd_obs <- cbind(psd_x_obs, psd_y_obs)
  
  # output for use in STAN model
  df_stan <- list(
    N = N,
    K = 2, # ILR(3-dimensional simplex) = 2-dimensional
    J = 3, # predictors: intercept + 2-dimensional ILR
    ilr_x_obs = ilr_x_obs, # predictor variables
    ilr_y_obs = ilr_y_obs, # outcome variables
    # data.frame with latent and observed values of both methods in % (inv-ILR)
    psd = cbind(id = 1:N, psd, psd_obs)
  )
  return(df_stan)
}


# testing 
# psd <- sim_data_simplex()
# 
# spc <- data.frame(
#   .name = c("x_obs_clay","x_obs_silt","x_obs_sand",
#             "y_obs_clay","y_obs_silt","y_obs_sand",
#             "x_true_clay","x_true_silt","x_true_sand",
#             "y_true_clay","y_true_silt","y_true_sand"),
#   .value = rep(c("clay","silt","sand"), 4)
# ) %>%
#   mutate(method = substr(.name, 1, 1),
#          obs = stringr::str_split_i(.name, "_", 2))
# 
# b <- psd$psd %>%
#   pivot_longer_spec(spc) %>%
#   ggtern(aes(silt, clay, sand, group = id)) +
#   facet_wrap(~ obs) +
#   geom_point(aes(color = method)) + geom_line(alpha = .2) 
# 
# a <- psd$psd %>%
#   pivot_longer_spec(spc) %>%
#   pivot_longer(c("clay","silt","sand"), 
#                names_to = "ps", values_to = "pct") %>%
#   pivot_wider(values_from = pct, 
#               names_from = method, names_prefix = "pct_") %>%
#   ggplot(aes(pct_x, pct_y, color = obs)) +
#   facet_wrap(~ ps) +
#   geom_point() +
#   geom_abline(intercept = 0, slope = 1, lty = 2)
# 
# ggpubr::ggarrange(a, b, nrow = 2)


library(cmdstanr)

mod <- cmdstan_model(here::here("source/stan-PSD/mvlinreg.stan"))

fit <- mod$sample(data = psd)

fit$summary()
fitsum <- fit$summary()

preds <- cbind(
  fitsum %>%
    filter(grepl("ilr_y_obs_rep", variable)) %>%
    filter(grepl("\\,1]", variable)) %>%
    select(mean),
  fitsum %>%
    filter(grepl("ilr_y_obs_rep", variable)) %>%
    filter(grepl("\\,2]", variable)) %>%
    select(mean)
) %>% 
  compositions::ilrInv() %>%
  data.frame()

ggtern(preds, aes(X1, X2, X3)) +
  geom_point()







