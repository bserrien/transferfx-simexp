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
  files = c(here("source/R/design-simexp-gamma.R"),
            here("source/R/simulate-data-gamma.R"),
            here("source/R/evaluate-predictions-gamma.R"),
            here("source/R/utils.R"))
)
rm(tidy_scenario, tidy_scenario_gamma, reg_dilution, scenario_labeller_gamma, 
   simexp_design5, simexp_design6, simexp_design7)

# fitted parameters on Italy/Portugal data
load(here::here("data/draws_params_hdi_ECEC.rda"))


### ---------------- ###
### Targets-pipeline ###
### ---------------- ###
list(
  # for each batch/rep: draw simulated data and fit Bayesian models on it
  # the function sim_data_ECEC returns a training and a validation dataset
  tar_stan_mcmc_rep_draws(
    name       = mcmc,
    stan_files = c(here("source/stan-ECEC/ECEC_linreg.stan"),
                   here("source/stan-ECEC/ECEC_linreglogtrafo.stan"),
                   here("source/stan-ECEC/ECEC_gammareg.stan"),
                   here("source/stan-ECEC/ECEC_gammareg_eiv_knowncvmex.stan"),
                   here("source/stan-ECEC/ECEC_gammareg_eiv_unknowncvmex.stan")),
    data = sim_data_ECEC(N = 200, draws_params_hdi),
    seed          = 123,
    chains        = 4, parallel_chains = 4,
    iter_warmup   = 1000,
    iter_sampling = 1000,
    refresh       = 0,
    batches       = 5,
    reps          = 1,
    stdout = R.utils::nullfile(),
    stderr = R.utils::nullfile()
  )
  
  # # get prediction summaries per model
  # tar_target(preds_linreg,
  #            summarise_predictions(mcmc_ECEC_linreg, mcmc_data),
  #            pattern = map(mcmc_gamma_linreg, mcmc_data)),
  # tar_target(preds_linreglogtrafo,
  #            summarise_predictions(mcmc_ECEC_linreglogtrafo, mcmc_data),
  #            pattern = map(mcmc_gamma_linreglogtrafo, mcmc_data)),
  # tar_target(preds_gammareg,
  #            summarise_predictions(mcmc_ECEC_gammareg, mcmc_data),
  #            pattern = map(mcmc_gammareg, mcmc_data)),
  # tar_target(preds_gammaregeivknowncvmex,
  #            summarise_predictions(mcmc_ECEC_gammareg_eiv_knowncvmex, mcmc_data),
  #            pattern = map(mcmc_gammareg_eiv_knowncvmex, mcmc_data)),
  # tar_target(preds_gammaregeivunknowncvmex,
  #            summarise_predictions(mcmc_ECEC_gammareg_eiv_unknowncvmex, mcmc_data),
  #            pattern = map(mcmc_gammareg_eiv_unknowncvmex, mcmc_data)),
  # 
  # # evaluate predictions
  # tar_target(
  #   predeval,
  #   eval_preds_gamma(preds_linreg, preds_linreglogtrafo,
  #                    preds_gammareg, preds_gammaregeivknowncvmex,
  #                    preds_gammaregeivunknowncvmex)
  # ),
  # 
  # # MCMC-diagnostics
  # tar_target(mcmcdx_linreg,
  #            mcmc_dx(mcmc_gamma_linreg),
  #            pattern = map(mcmc_gamma_linreg)),
  # tar_target(mcmcdx_linreglogtrafo,
  #            mcmc_dx(mcmc_gamma_linreglogtrafo),
  #            pattern = map(mcmc_gamma_linreglogtrafo)),
  # tar_target(mcmcdx_gammareg,
  #            mcmc_dx(mcmc_gammareg),
  #            pattern = map(mcmc_gammareg)),
  # tar_target(mcmcdx_gammaregeivknowncvmex,
  #            mcmc_dx(mcmc_gammareg_eiv_knowncvmex),
  #            pattern = map(mcmc_gammareg_eiv_knowncvmex)),
  # tar_target(mcmcdx_gammaregeivunknowncvmex,
  #            mcmc_dx(mcmc_gammareg_eiv_unknowncvmex),
  #            pattern = map(mcmc_gammareg_eiv_unknowncvmex)),
  # tar_target(
  #   mcmcdx,
  #   combine_mcmcdx(mcmcdx_linreg, mcmcdx_linreglogtrafo, mcmcdx_gammareg,
  #                  mcmcdx_gammaregeivknowncvmex, mcmcdx_gammaregeivunknowncvmex)
  # )
)

