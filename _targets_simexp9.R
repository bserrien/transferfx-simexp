# _targets_simexp9.R
library(targets)
library(tarchetypes)
library(stantargets)
library(posterior) |> suppressPackageStartupMessages()
library(tidyverse) |> suppressPackageStartupMessages()
library(here) |> suppressPackageStartupMessages()
library(quarto)
library(crew)

tar_option_set(
  controller = crew_controller_local(workers = 5)
)
tar_source(
  files = c(here("source/R/design-simexp-simplex.R"),
            here("source/R/simulate-data-simplex.R"),
            here("source/R/evaluate-predictions-simplex.R"),
            here("source/R/utils.R"))
)

labs <- colnames(simexp_design9)[grepl("_label", colnames(simexp_design9))]


### ---------------- ###
### Targets-pipeline ###
### ---------------- ###
list(
  # part of the pipeline to map over scenario's:
  mapped <- tar_map(
    unlist = FALSE,
    values = simexp_design9,
    names  = all_of(labs),
    
    # for each batch/rep: draw simulated data and fit Bayesian models on it
    # the function sim_data_simplex returns both a training 
    # and a validation dataset
    tar_stan_mcmc_rep_draws(
      name       = mcmc,
      stan_files = c(here("source/stan-PSD/mvlinreg.stan")),
      data = sim_data_simplex(
        
      ),
      seed          = 123,
      chains        = 4, parallel_chains = 4,
      iter_warmup   = 1000,
      iter_sampling = 1000,
      refresh       = 0,
      batches       = 1,
      reps          = 1,
      stdout = R.utils::nullfile(),
      stderr = R.utils::nullfile()
    )
  )
  
)
