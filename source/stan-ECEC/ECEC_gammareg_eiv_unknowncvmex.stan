// gamma EIV-regression model with prior on CV of the measurement error

data {
  int<lower=1> N;            // number of observations
  vector<lower=0>[N] x_obs;  // observed x
  vector<lower=0>[N] y_obs;  // observed y
  // --- prediction for new x_obs ---
  int<lower=0> N_new;               // number of new observations to predict
  vector<lower=0>[N_new] x_obs_new; // their observed (error-prone) x values
}

transformed data {
  // not needed
}

parameters {
  real<lower=0> shape;  // shape for the y|x gamma
  real beta0;           // log(E[y]) = beta0 + beta1*log(x)
  real<lower=0> beta1;  // log(E[y]) = beta0 + beta1*log(x)
  // latent variables
  real<lower=0> mu_x;
  real<lower=0> cv_x;
  vector<lower=0>[N] x_true;
  // measurement error: shape of the gamma
  real<lower=0> shape_mex;
  // latent true x for the *new* (to-be-predicted) observations
  vector<lower=0>[N_new] x_true_new;
}

transformed parameters {
  // regression on x_true: conditional mean on log-scale
  vector[N] mu = exp(beta0 + beta1 * log(x_true));
  // latent variable: shape/rate of the gamma
  real<lower=0> shape_x = inv_square(cv_x);
  real<lower=0> rate_x  = shape_x / mu_x;
  // regression layer for new observations
  vector[N_new] mu_new = exp(beta0 + beta1 * log(x_true_new));
}

model {
  // priors
  beta0 ~ normal(0, 5);
  beta1 ~ normal(1, 1);
  shape ~ lognormal(0, 1); 
  // latent
  mu_x   ~ lognormal(0, 1);
  cv_x   ~ lognormal(0, 1);
  x_true ~ gamma(shape_x, rate_x);
  // measurement error
  shape_mex ~ lognormal(0, 1);
  x_obs ~ gamma(shape_mex, shape_mex ./ x_true);
  // likelihood
  y_obs ~ gamma(shape, shape ./ mu);
  // --- prediction rows ---
  if (N_new > 0) {
    x_true_new ~ gamma(shape_x, rate_x);
    x_obs_new  ~ gamma(shape_mex, shape_mex ./ x_true_new);
  }
}

generated quantities {
  // posterior predictive draws for the new observations
  vector[N_new] y_new_rep;
  for (n in 1:N_new) {
    y_new_rep[n] = gamma_rng(shape, shape / mu_new[n]);
  }
}
