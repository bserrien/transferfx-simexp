# _targets_simexp.R
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
  files = here("source", "R")
)

labs <- colnames(simexp_design5)[grepl("_label", colnames(simexp_design5))]


### ---------------- ###
### Targets-pipeline ###
### ---------------- ###
list(
  # part of the pipeline to map over scenario's:
  mapped <- tar_map(
    unlist = FALSE,
    values = simexp_design5,
    names  = all_of(labs),
    
    # for each batch/rep: draw simulated data and fit Bayesian models on it
    # the function sim_data returns both a training and a validation dataset
    tar_stan_mcmc_rep_draws(
      name       = mcmc,
      stan_files = c(here("source/stan/linreg.stan")),
      data = sim_data_gamma(
        N               = sample_size,
        ratio_cvmex_cvx = ratio_cvmex_cvx
      ),
      seed          = 123,
      chains        = 4, parallel_chains = 4,
      iter_warmup   = 1000,
      iter_sampling = 1000,
      refresh       = 0,
      batches       = 5,
      reps          = 2,
      stdout = R.utils::nullfile(),
      stderr = R.utils::nullfile()
    ),
    
    # evaluate predictions
    tar_target(preds_linreg,
               predict_linreg(mcmc_linreg, mcmc_data),
               pattern = map(mcmc_linreg, mcmc_data)),
    tar_target(
      predeval,
      eval_preds(preds_linreg, 
                 fx_valmetrics = val_metrics_gamma)
    )
  ),
  
  # combine results across scenario's
  tar_combine(
    predeval_summary,
    mapped[["predeval"]],
    command = bind_rows(!!!.x, .id = "scenario")
  )
)

