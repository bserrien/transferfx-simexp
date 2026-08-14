# _targets-run-simexp9.R

rstudioapi::restartSession()

Sys.setenv(TAR_PROJECT = "project_simexp9")

library(targets)
library(tarchetypes)
library(tidyverse) |> suppressPackageStartupMessages()

tar_visnetwork()
#tar_visnetwork(physics = TRUE, targets_only = TRUE)

tar_make()
#tar_make(callr_function = NULL, use_crew = FALSE, as_job = FALSE)


tar_objects()

tar_load(mcmc_mvlinreg_knownSDme_Nsample100_AlphaIlr0_BetaIlr1_SigmaIlr0.1_SDmex0.1_RatioSDme1_CorrMe0_c57fd7db0b4834ce)

tar_load(preds_mvlinreg_Nsample100_AlphaIlr0_BetaIlr1_SigmaIlr0.1_SDmex0.1_RatioSDme1_CorrMe0_4814ac7cfae21f23)

tar_load(preds_summary_Nsample100_AlphaIlr0_BetaIlr1_SigmaIlr0.1_SDmex0.1_RatioSDme1_CorrMe0)

