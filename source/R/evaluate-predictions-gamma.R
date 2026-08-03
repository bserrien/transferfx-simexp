# evaluate-predictions-gamma.R
#
# set of R functions to evaluate the predictions in experiments with 
# gamma-distributed variables


#' summarise_predictions
#' summarise predictions and bind with validation data
summarise_predictions <- function(mcmc, data) {
  #browser()
  preds <- mcmc %>%
    select(.rep, .dataset_id, contains("y_new_rep")) %>%
    nest(.by = c(.rep, .dataset_id), .key = "samples") %>%
    mutate(preds = map(samples, predx_summary)) %>%
    select(-samples) %>%
    unnest(preds) %>%
    mutate(.by = c(.rep, .dataset_id), uniqueid = 1:n())
  validation_data <- data.table::rbindlist(
    lapply(data, get_validation_data)
  ) %>% mutate(.by = .dataset_id, uniqueid = 1:n())
  validation_data %>%
    left_join(preds, by = c(".dataset_id","uniqueid")) %>%
    select(.rep, .dataset_id, uniqueid, 
           y_true_new, y_obs_new, yhat, yhat_ll, yhat_ul)
}

#' predx_summary
#' helper function for summarise_predictions()
predx_summary <- function(samples) {
  samples_matrix <- t(as.matrix(samples))
  data.frame(
    yhat    = apply(samples_matrix, 1, mean),
    yhat_ll = apply(samples_matrix, 1, quantile, probs = .025),
    yhat_ul = apply(samples_matrix, 1, quantile, probs = .975)
  )
}

#' get_validation_data
#' helper function for summarise_predictions()
get_validation_data <- function(data) {
  data.frame(
    .dataset_id = rep(data$.dataset_id, data$N_new),
    x_true_new  = data$x_true_new,
    y_true_new  = data$y_true_new,
    x_obs_new   = data$x_obs_new,
    y_obs_new   = data$y_obs_new
  )
}


#' eval_preds_gamma
#' evaluate prediction models for gamma-distributed variables
#' @param ... set of models to evaluate, passed as different arguments
eval_preds_gamma <- function(...) {
  preds  <- list(...)
  names(preds) <- stringr::str_split_i(
    as.character(as.list(substitute(list(...)))[-1]),
    "_", 2
  )
  for (i in 1:length(preds)) {
    preds[[i]] <- preds[[i]] %>%
      mutate(model = names(preds)[i])
  }
  data.table::rbindlist(
    lapply(preds, val_metrics_gamma)
  )
}

#' val_metrics_gamma
#' helper function for `eval_preds_gamma()`: 
#' calculation of the validation metrics
val_metrics_gamma <- function(df) {
  df %>%
    summarise(
      .by = c(model, .rep),
      MAE  = mean(abs(yhat - y_obs_new)),
      RMSE = sqrt(mean((yhat - y_obs_new)^2)),
      MPE  = mean(yhat - y_obs_new),
      R2   = 1 - sum((y_obs_new - yhat)^2) / sum((y_obs_new-mean(y_obs_new))^2),
      SDPE = sd(yhat - y_obs_new),
      PICP = mean(between(y_obs_new, yhat_ll, yhat_ul)),
      # specific metrics for gamma: predictions should be strictly positive
      PNEG   = mean(yhat <= 0),
      PNEGll = mean(yhat_ll <= 0)
    ) 
}
