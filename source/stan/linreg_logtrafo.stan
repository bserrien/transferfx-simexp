// basic linear regression model with log-transformed variables

data {
  int<lower=1> N;   // number of observations
  vector[N] x_obs;  // observed x
  vector[N] y_obs;  // observed y
}

transformed data {
  vector[N] x_obs_log;
  x_obs_log = log(x_obs);
  vector[N] y_obs_log;
  y_obs_log = log(y_obs);
}

parameters {
  real b_Intercept;       // intercept on log-scale
  real<lower=0> b_x_obs;  // slope on log-scale
  real<lower=0> sigma;    // residual sd on log-scale
}

model {
  // prior
  b_Intercept ~ normal(0, 1);
  b_x_obs     ~ normal(1, .5);
  sigma       ~ lognormal(0, 0.5);
  // likelihood
  y_obs_log ~ normal(b_Intercept + b_x_obs * x_obs_log, sigma);
}

generated quantities {
  // not used for now (needed for WAIC)
  // vector[N] y_rep = to_vector(
  //   normal_rng(b_Intercept + b_x_obs * x_obs, sigma)
  // );
  // vector[N] log_lik = normal_lpdf(
  //   y_obs | b_Intercept + b_x_obs * x_obs, sigma
  // );
}
