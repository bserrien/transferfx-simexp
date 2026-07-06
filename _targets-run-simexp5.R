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

tar_prune()

tar_objects()


tar_load(mcmc_linreg_Nsample100_Mux158.4615_CVx0.696733_Alpha0_Beta1_CVy0.05_Taux0.05_Tauxy1_Rho0_6a87be3cf2710f36)
tar_load(mcmcdx_summary)


tar_load(predeval_summary)


