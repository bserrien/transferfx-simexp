// gamma EIV-regression model for Austrian ECEC data

data {
  int<lower=1> N;            // number of observations
  vector<lower=0>[N] x_obs;  // observed x
  vector<lower=0>[N] y_obs;  // observed y
}

transformed data {
  // average of log-transformed x (for centering beta0)
  real log_x_bar = mean(log(x_obs));
}

parameters {
  real<lower=0> shape;  // shape for the y|x gamma
  real beta0c;          // log(E[y]) = beta0c + beta1*log(x)
  real<lower=0> beta1;  // log(E[y]) = beta0c + beta1*log(x)
  // latent variables
  real<lower=0> mu_x;
  real<lower=0> cv_x;
  vector<lower=0>[N] x_true;
  // measurement error: shape of the gamma
  real<lower=0> shape_mex;
}

transformed parameters {
  // regression on x_true: conditional mean on log-scale
  // center the predictor for more stable sampling
  vector[N] mu = exp(beta0c + beta1 * (log(x_true) - log_x_bar));
  // original-scale intercept 
  real beta0 = beta0c - beta1 * log_x_bar;
  // latent variable: shape/rate of the gamma
  real<lower=0> shape_x = inv_square(cv_x);
  real<lower=0> rate_x  = shape_x / mu_x;
}

model {
  // priors
  beta0c ~ normal(log_x_bar, 1);
  beta1 ~ normal(1, .5);
  shape ~ lognormal(0, 1);
  // latent: informed prior based on Austrian data
  mu_x   ~ normal(181, 10);
  cv_x   ~ lognormal(0, 1);
  x_true ~ gamma(shape_x, rate_x);
  // measurement error
  shape_mex ~ lognormal(0, 1);
  x_obs ~ gamma(shape_mex, shape_mex ./ x_true);
  // likelihood
  y_obs ~ gamma(shape, shape ./ mu);
}

generated quantities {
  array[N] real y_rep;
  for (n in 1:N) y_rep[n] = gamma_rng(shape, shape ./ mu[n]);
}
