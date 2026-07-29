// basic linear regression model applied to gamma variables
// with prediction-on-the-fly

data {
  int<lower=1> N;   // number of observations
  vector[N] x_obs;  // observed x
  vector[N] y_obs;  // observed y
  // new data to predict:
  int<lower=1> N_new;
  vector[N_new] x_obs_new;
}

parameters {
  real beta0;          // intercept
  real<lower=0> beta1; // slope
  real<lower=0> sigma; // residual sd
}

model {
  // prior
  beta0 ~ normal(0, 5);
  beta1 ~ normal(1, 1);
  sigma ~ lognormal(0, 1);
  // likelihood
  y_obs ~ normal(beta0 + beta1 * x_obs, sigma);
}

generated quantities {
  // draws from posterior predictive distribution new observations:
  vector[N_new] y_new_rep;
  for (i in 1:N_new) {
    y_new_rep[i] = normal_rng(beta0 + beta1 * x_obs_new[i], sigma);
  }
}
