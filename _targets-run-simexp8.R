# _targets-run-simexp8.R

rstudioapi::restartSession()

Sys.setenv(TAR_PROJECT = "project_simexp8")

library(targets)
library(tarchetypes)
library(tidyverse) |> suppressPackageStartupMessages()

tar_visnetwork()
#tar_visnetwork(physics = TRUE, targets_only = TRUE)

tar_make()
#tar_make(callr_function = NULL, use_crew = FALSE, as_job = FALSE)


tar_objects()

tar_load(predeval)

tar_load(preds_gammareg_2a2667326b8f11ef)
preds_gammareg_2a2667326b8f11ef %>%
  slice_sample(n = 10) %>%
  ggplot() +
  geom_point(aes(y_true_new, y_obs_new), color = "red") +
  geom_point(aes(y_true_new, yhat)) +
  geom_errorbar(aes(y_true_new, yhat, ymin = yhat_ll, ymax = yhat_ul))

tar_load(preds_linreg_b508c06357f4510d)
preds_linreg_b508c06357f4510d %>%
  slice_sample(n = 10) %>%
  ggplot() +
  geom_point(aes(y_true_new, y_obs_new), color = "red") +
  geom_point(aes(y_true_new, yhat)) +
  geom_errorbar(aes(y_true_new, yhat, ymin = yhat_ll, ymax = yhat_ul))

tar_load(preds_gammaregeivunknowncvmex_72990a71c60457b7)
preds_gammaregeivunknowncvmex_72990a71c60457b7 %>%
  slice_sample(n = 10) %>%
  ggplot() +
  geom_point(aes(y_true_new, y_obs_new), color = "red") +
  geom_point(aes(y_true_new, yhat)) +
  geom_errorbar(aes(y_true_new, yhat, ymin = yhat_ll, ymax = yhat_ul))
