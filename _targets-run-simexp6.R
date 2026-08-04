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


# file management: move intermediate targets to Google Drive
source(here::here("source/R/file-management.R"))
obj2keep <- c("predeval_summary","mcmcdx_summary")

move_targets_to_gdrive(
  tar_path_store(),
  obj2keep,
  "G:/Mijn Drive/data/SoilHarmony/simexp_tf"
)

