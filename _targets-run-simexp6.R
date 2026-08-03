# _targets-run-simexp6.R

rstudioapi::restartSession()

Sys.setenv(TAR_PROJECT = "project_simexp6")

library(targets)
library(tarchetypes)
library(tidyverse) |> suppressPackageStartupMessages()

tar_visnetwork()
#tar_visnetwork(physics = TRUE, targets_only = TRUE)

tar_make()
#tar_make(callr_function = NULL, use_crew = FALSE, as_job = FALSE)


tar_objects()

tar_load(mcmc_gammareg_eiv_unknowncvmex_Nsample200_Mux1_CVx0.5_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy0.9_Rho0.5_b0babece05890e24)

mcmc_gammareg_eiv_unknowncvmex_Nsample200_Mux1_CVx0.5_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy0.9_Rho0.5_b0babece05890e24 %>%
  ggplot(aes(beta0, beta1, color = factor(.chain))) +
  facet_wrap(~ .rep) +
  geom_point()

