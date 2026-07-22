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
