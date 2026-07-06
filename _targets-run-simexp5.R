# _targets-run-simexp5.R

rstudioapi::restartSession()

Sys.setenv(TAR_PROJECT = "project_simexp5")

library(targets)
library(tarchetypes)
library(tidyverse) |> suppressPackageStartupMessages()

tar_visnetwork()
#tar_visnetwork(physics = TRUE, targets_only = TRUE)

tar_make()
#tar_make(callr_function = NULL, use_crew = FALSE, as_job = FALSE)

# total runtime of the pipeline (per target?)
# ??????????????????????

tar_meta(fields = warnings, complete_only = TRUE) %>% View()

tar_manifest() %>% View()

tar_prune_list()
tar_prune()

tar_objects()


tar_load(mcmc_linreg_Nsample100_Mux158.4615_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_6a87be3cf2710f36)
tar_load(mcmcdx_summary)


tar_load(predeval_summary)

tar_load(mcmc_data_Nsample100_Mux5_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_607315fe597c4c84)


tar_load(mcmc_data_Nsample100_Mux158.4615_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_83da79d6e79412d9)
hist(mcmc_data_Nsample100_Mux158.4615_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_83da79d6e79412d9[[1]]$x_true)

curve(dgamma(x, shape = 0.696733^(-2), rate = 0.696733^(-2)/158.4615), from = 0, to = 600)

tar_load(mcmc_data_Nsample100_Mux5_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_607315fe597c4c84)
hist(mcmc_data_Nsample100_Mux5_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_607315fe597c4c84[[1]]$x_true)
summary(mcmc_data_Nsample100_Mux5_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_607315fe597c4c84[[1]]$x_true)

curve(dgamma(x, shape = 0.696733^(-2), rate = 0.696733^(-2)/5), from = 0, to = 30)

