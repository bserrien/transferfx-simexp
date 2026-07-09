// gamma EIV-regression model with known CV of the measurement error

data {
  int<lower=1> N;            // number of observations
  vector<lower=0>[N] x_obs;  // observed x
  vector<lower=0>[N] y_obs;  // observed y
  real<lower=0> cv_mex;      // known CV of the measurement error
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
}

transformed parameters {
  // regression on x_true: conditional mean on log-scale
  vector[N] mu;
  mu = exp(beta0 + beta1 * log(x_true));
  // measurement error: shape of the gamma
  real<lower=0> shape_mex;
  shape_mex = inv_square(cv_mex);
  // latent variable: shape/rate of the gamma
  real<lower=0> shape_x;
  shape_x = inv_square(cv_x);
  real<lower=0> rate_x;
  rate_x = shape_x / mu_x;
}

model {
  // priors
  beta0 ~ normal(0, 1);
  beta1 ~ normal(1, .5);
  shape ~ exponential(.002);
  // latent
  mu_x   ~ normal(1, .5);
  cv_x   ~ normal(1, .5);
  x_true ~ gamma(shape_x, rate_x);
  // measurement error
  x_obs ~ gamma(shape_mex, shape_mex ./ x_true);
  // likelihood
  y_obs ~ gamma(shape, shape ./ mu);
}

generated quantities {
  // not used for now (needed for WAIC)
}
