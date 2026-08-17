// basic linear regression model with log-transformed variables

data {
  int<lower=1> N;   // number of observations
  vector[N] x_obs;  // observed x
  vector[N] y_obs;  // observed y
  // for predictions on new data
  int<lower=1> N_new;
  vector[N_new] x_obs_new;
}

transformed data {
  vector[N] x_obs_log = log(x_obs);
  vector[N] y_obs_log = log(y_obs);
  vector[N_new] x_obs_new_log = log(x_obs_new);
}

parameters {
  real beta0;           // intercept on log-scale
  real<lower=0> beta1;  // slope on log-scale
  real<lower=0> sigma;  // residual sd on log-scale
}

model {
  // prior
  beta0 ~ normal(0, 1);
  beta1 ~ normal(1, .5);
  sigma ~ lognormal(0, 0.5);
  // likelihood
  y_obs_log ~ normal(beta0 + beta1 * x_obs_log, sigma);
}

generated quantities {
  // predictions for new observations
  vector[N_new] y_new_rep;
  vector[N_new] mu_mean_new; // Stores the corrected conditional mean
  
  for (i in 1:N_new) {
    // Posterior predictive distribution (simulated observable data)
    y_new_rep[i] = exp(normal_rng(beta0 + beta1 * x_obs_new_log[i], sigma));
    // Expected value E[y|x] (incorporates the log-normal variance correction)
    mu_mean_new[i] = exp(beta0 + beta1 * x_obs_new_log[i] + 0.5 * square(sigma));
  }}
