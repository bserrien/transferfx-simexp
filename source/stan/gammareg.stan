// gamma regression model

data {
  int<lower=1> N;   // number of observations
  vector<lower=0>[N] x_obs;  // observed x
  vector<lower=0>[N] y_obs;  // observed y
}

transformed data {
  vector[N] x_obs_log;
  x_obs_log = log(x_obs);
}

parameters {
  real<lower=0> shape;
  real beta0;
  real<lower=0> beta1;
}

transformed parameters {
  vector[N] mu;
  vector[N] rate;
  mu   = exp(beta0 + beta1 * x_obs_log);
  rate = shape / mu;
}

model {
  // priors
  beta0 ~ normal(0, 1);
  beta1 ~ normal(1, .5);
  shape ~ exponential(.002);
  // likelihood
  y_obs ~ gamma(shape, rate);
}

generated quantities {
  // not used for now (needed for WAIC)
}
