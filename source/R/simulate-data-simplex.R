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
  ilr_x_obs <- cbind(X0 = 1, ilr_x_obs)
  ilr_y_obs <- ilr_y + eps_xy[, 3:4]
  
  # transform observed to PSD (%)
  psd_x_obs <- data.frame(compositions::ilrInv(ilr_x_obs[, 2:3]))
  colnames(psd_x_obs) <- c("x_obs_clay","x_obs_silt","x_obs_sand")
  psd_y_obs <- data.frame(compositions::ilrInv(ilr_y_obs))
  colnames(psd_y_obs) <- c("y_obs_clay","y_obs_silt","y_obs_sand")
  psd_obs <- cbind(psd_x_obs, psd_y_obs)
  
  # same procedure for validation data
  N_new     <- 1000
  ilr_x_new <- data.frame(MASS::mvrnorm(N_new, mu_ilr, cov_ilr))
  ilr_y_new <- data.frame(
    Y1 = rnorm(N_new, alpha_ilr[1] + beta_ilr[1] * ilr_x_new$X1, sigma_ilr[1]),
    Y2 = rnorm(N_new, alpha_ilr[2] + beta_ilr[2] * ilr_x_new$X2, sigma_ilr[2])
  )
  psd_x_new           <- data.frame(compositions::ilrInv(ilr_x_new))
  colnames(psd_x_new) <- c("x_true_clay","x_true_silt","x_true_sand")
  psd_y_new           <- data.frame(compositions::ilrInv(ilr_y_new))
  colnames(psd_y_new) <- c("y_true_clay","y_true_silt","y_true_sand")
  psd_new             <- cbind(psd_x_new, psd_y_new)
  eps_xy_new <- MASS::mvrnorm(
    n     = N_new, 
    mu    = rep(0, 4), 
    Sigma = matrix(
      c(sd_mex1^2, 0, corr_mexy * sd_mex1 * sd_mey1, 0,
        0, sd_mex2^2, 0, corr_mexy * sd_mex2 * sd_mey2,
        corr_mexy * sd_mex1 * sd_mey1, 0, sd_mey1^2, 0,
        0, corr_mexy * sd_mex2 * sd_mey2, 0, sd_mey2^2), 
      byrow = T, nrow = 4
    )
  )
  ilr_x_obs_new <- ilr_x_new + eps_xy_new[, 1:2]
  ilr_x_obs_new <- cbind(X0 = 1, ilr_x_obs_new)
  ilr_y_obs_new <- ilr_y_new + eps_xy_new[, 3:4]
  psd_x_obs_new           <- data.frame(compositions::ilrInv(ilr_x_obs_new[, 2:3]))
  colnames(psd_x_obs_new) <- c("x_obs_clay","x_obs_silt","x_obs_sand")
  psd_y_obs_new           <- data.frame(compositions::ilrInv(ilr_y_obs_new))
  colnames(psd_y_obs_new) <- c("y_obs_clay","y_obs_silt","y_obs_sand")
  psd_obs_new             <- cbind(psd_x_obs_new, psd_y_obs_new)
  
  # output for use in STAN model
  df_stan <- list(
    N = N,
    K = 2, # ILR(3-dimensional simplex) = 2-dimensional
    J = 3, # predictors: intercept + 2-dimensional ILR
    # Coerce to matrices for Stan stability
    ilr_x_obs = as.matrix(ilr_x_obs), 
    ilr_y_obs = as.matrix(ilr_y_obs),
    # data.frame with latent and observed values of both methods in % (inv-ILR)
    psd = cbind(id = 1:N, psd, psd_obs),
    # validation data
    N_new         = N_new,
    ilr_x_obs_new = ilr_x_obs_new,
    psd_new       = cbind(id = 1:N_new, psd_new, psd_obs_new)
  )
  return(df_stan)
}


# # testing
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
#   ggtern::ggtern(aes(silt, clay, sand, group = id)) +
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
# 
# 
# library(cmdstanr)
# 
# mod <- cmdstan_model(here::here("source/stan-PSD/mvlinreg.stan"))
# 
# fit <- mod$sample(data = psd)
# 
# fitsum <- fit$summary()
# fitsum
# 
# draws_df <- fit$draws(format = "data.frame")
# 
# 
# 
# predict_psd <- function(draws_ilr) {
#   
#   draws_new_obs <- draws_ilr %>%
#     select(.draw, contains("ilr_y_obs_new_rep"))
#   
#   spc <- data.frame(
#     .name = colnames(draws_new_obs)[2:ncol(draws_new_obs)]
#   ) %>%
#     mutate(
#       .value = case_when(grepl(",1]", .name) ~ "X1",
#                          grepl(",2]", .name) ~ "X2"),
#       obs = stringr::str_extract(.name, "(?<=\\[)\\d+")
#     )
#   
#   draws_new_obs_long <- draws_new_obs %>%
#     pivot_longer_spec(spc)
#   draws_new_obs_psd <- compositions::ilrInv(
#     draws_new_obs_long[, c("X1","X2")]
#   )
#   colnames(draws_new_obs_psd) <- c("clay","silt","sand")
#   
#   pred_summary <- cbind(draws_new_obs_long, draws_new_obs_psd) %>%
#     summarise(
#       .by = obs,
#       clay_hat = mean(clay),
#       silt_hat = mean(silt),
#       sand_hat = mean(sand),
#       clay_ll  = quantile(clay, .025),
#       clay_ul  = quantile(clay, .975),
#       silt_ll  = quantile(silt, .025),
#       silt_ul  = quantile(silt, .975),
#       sand_ll  = quantile(sand, .025),
#       sand_ul  = quantile(sand, .975)
#     )
# 
#   return( pred_summary )
# }
# 
# preds_psd <- predict_psd(draws_df)
# 
# 
# 
# 
# 
# 
# idx <- sample(1:nrow(preds_psd), 2)
# psd$psd_new[idx, ] %>% select(contains("y_")) %>% print()
# preds_psd[idx, ] %>% print()
# preds_psd[idx, ] %>%
#   ggtern::ggtern(aes(silt_hat, clay_hat, sand_hat)) +
#   geom_point() +
#   geom_errorbarL(aes(Lmin = silt_ll, Lmax = silt_ul)) +
#   geom_errorbarT(aes(Tmin = clay_ll, Tmax = clay_ul)) +
#   geom_errorbarR(aes(Rmin = sand_ll, Rmax = sand_ul)) +
#   geom_point(
#     data = psd$psd_new[idx, ], 
#     aes(y_obs_silt, y_obs_clay, y_obs_sand), 
#     color = "red"
#   )
# 
# 
# 
# cbind(psd$psd_new, preds_psd) %>%
#   summarise(
#     MPE_clay = mean(y_obs_clay - clay_hat),
#     MPE_silt = mean(y_obs_silt - silt_hat),
#     MPE_sand = mean(y_obs_sand - sand_hat),
#     PICP_clay = mean(between(y_obs_clay, clay_ll, clay_ul)),
#     PICP_silt = mean(between(y_obs_silt, silt_ll, silt_ul)),
#     PICP_sand = mean(between(y_obs_sand, sand_ll, sand_ul))
#   )
# 
# 
# 
