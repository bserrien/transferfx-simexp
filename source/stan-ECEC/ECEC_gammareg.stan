// gamma GLM regression model

data {
  int<lower=1> N;   // number of observations
  vector<lower=0>[N] x_obs;  // observed x
  vector<lower=0>[N] y_obs;  // observed y
  // predictions on new observations
  int<lower=1> N_new;
  vector<lower=0>[N_new] x_obs_new;
}

transformed data {
  vector[N] x_obs_log = log(x_obs);
  vector[N_new] x_obs_new_log = log(x_obs_new);
}

parameters {
  real<lower=0> shape;
  real beta0;
  real<lower=0> beta1;
}

transformed parameters {
  vector[N] mu         = exp(beta0 + beta1 * x_obs_log);
  vector[N_new] mu_new = exp(beta0 + beta1 * x_obs_new_log);
}

model {
  // priors
  beta0 ~ normal(0, 1);
  beta1 ~ normal(1, .5);
  shape ~ lognormal(0, 1); // exponential(.002);
  // likelihood
  y_obs ~ gamma(shape, shape ./ mu);
}

generated quantities {
  // predictions for new observations
  vector[N_new] y_new_rep;
  for (i in 1:N_new) {
    y_new_rep[i] = gamma_rng(shape, shape ./ mu_new[i]);
  }
}
