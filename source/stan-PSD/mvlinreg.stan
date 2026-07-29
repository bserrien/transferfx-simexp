// multivariate linear regression

data {
  int<lower=0> N; // nr. observations
  int<lower=0> K; // 2-dimensional outcome variable (ILR of ref method)
  int<lower=0> J; // 2-dimensional predictor variable (ILR of non-ref method)
  array[N] vector[K] ilr_y_obs;
  array[N] vector[J] ilr_x_obs;
}

transformed data {
  //
}

parameters {
  // regression coefficients
  matrix[K, J] beta;   
  // residuals: 2-dimensional via Cholesky decomp. of the corr-matrix
  cholesky_factor_corr[K] L_Omega; 
  vector<lower=0>[K] l_sigma; 
  
}

transformed parameters {
  // get the covariance matrix from the Cholesky-factorization
  matrix[K, K] L_Sigma = diag_pre_multiply(l_sigma, L_Omega);
  // mean-part of the regression model
  array[N] vector[K] Mu;
  for (i in 1:N) {
    Mu[i] = beta * ilr_x_obs[i];
  }
}

model {
  // prior
  L_Omega ~ lkj_corr_cholesky(4);
  l_sigma ~ cauchy(0, 2.5);
  to_vector(beta) ~ normal(0, 10);
  // likelihood
  ilr_y_obs ~ multi_normal_cholesky(Mu, L_Sigma);
}

generated quantities {
  // posterior predictive check
  array[N] vector[K] ilr_y_obs_rep;
  for (i in 1:N) {
    ilr_y_obs_rep[i] = multi_normal_cholesky_rng(Mu[i], L_Sigma);
  }
} 
