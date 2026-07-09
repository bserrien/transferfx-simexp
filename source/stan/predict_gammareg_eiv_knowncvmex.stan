// Prediction-only program for the Gamma error-in-variables model.
//
// Purpose: given posterior draws of the hyperparameters from a PREVIOUSLY
// fitted eivreg_gamma_known_cvmex.stan run, and a set of NEW x_obs values
// (arriving after fitting, with no y available), produce posterior
// predictive draws of y -- without refitting the whole model.
//
// Since Gamma-on-Gamma has no closed-form posterior for x_true_new, this
// program samples it with a small independence Metropolis sampler inside
// generated quantities:
//   target(x)   propto prior(x; shape_x, rate_x) * measurement_lik(x_obs_new | x)
//   proposal(x) = Gamma(shape_prop, shape_prop / x_obs_new)   [mean = x_obs_new]
// Centering the proposal at x_obs_new (rather than at the prior) gives much
// better mixing whenever the measurement error is small, since draws from
// the prior would otherwise rarely land near the region the likelihood
// actually favors.
//
// Run with a fixed-parameter sampler (no real "parameters" to sample):
//   cmdstanr: model$sample(data = ..., fixed_param = TRUE, chains = 1, iter_sampling = 1)
//   rstan:    sampling(model, data = ..., algorithm = "Fixed_param", chains = 1, iter = 1)

functions {
  // One independence-MH draw of x_true_new given hyperparameters and one
  // observed (error-prone) x. Proposal is a Gamma with MEAN = x_obs_i
  // (shape given by shape_prop, rate = shape_prop / x_obs_i), which mixes
  // far better than proposing from the prior whenever the measurement
  // error is small (the prior-proposal sampler wastes almost all draws
  // far from x_obs_i in that regime).
  //
  // Since proposal != prior here, the prior no longer cancels from the
  // acceptance ratio -- we need the full target/proposal ratio:
  //   log_alpha = [log prior(x') + log lik(x') - log q(x')]
  //             - [log prior(x)  + log lik(x)  - log q(x)]
  real sample_x_true_new_rng(real x_obs_i, real shape_x, real rate_x,
                              real shape_mex, real shape_prop, int n_iter) {
    real rate_prop = shape_prop / x_obs_i;   // fixed proposal, mean = x_obs_i

    real x_cur = gamma_rng(shape_prop, rate_prop);
    real logtarget_cur = gamma_lpdf(x_cur | shape_x, rate_x)
                        + gamma_lpdf(x_obs_i | shape_mex, shape_mex / x_cur);
    real logq_cur = gamma_lpdf(x_cur | shape_prop, rate_prop);

    for (iter in 1:n_iter) {
      real x_prop = gamma_rng(shape_prop, rate_prop);
      real logtarget_prop = gamma_lpdf(x_prop | shape_x, rate_x)
                           + gamma_lpdf(x_obs_i | shape_mex, shape_mex / x_prop);
      real logq_prop = gamma_lpdf(x_prop | shape_prop, rate_prop);

      real log_alpha = (logtarget_prop - logq_prop) - (logtarget_cur - logq_cur);
      if (log(uniform_rng(0, 1)) < log_alpha) {
        x_cur = x_prop;
        logtarget_cur = logtarget_prop;
        logq_cur = logq_prop;
      }
    }
    return x_cur;
  }
}

data {
  // posterior draws from the ORIGINAL fit (extract these from your fit
  // object in R/Python and pass them in as plain vectors of length S)
  int<lower=1> S;                          // number of posterior draws to use
  vector[S] mu_x_draws;
  vector<lower=0>[S] shape_x_draws;
  vector[S] beta0_draws;
  vector[S] beta1_draws;
  vector<lower=0>[S] shape_draws;

  real<lower=0> cv_mex;                    // same known CV used at fitting time

  int<lower=0> N_new;                      // number of new points to predict
  vector<lower=0>[N_new] x_obs_new;

  int<lower=1> n_mh_iter;                  // MH iterations per draw (try 20-50;
                                            // this proposal mixes much faster than
                                            // proposing from the prior)
  real<lower=0> shape_prop;                // shape of the proposal Gamma(shape_prop,
                                            // shape_prop/x_obs_new); start with shape_mex
                                            // (i.e. inv_square(cv_mex)), widen (lower it)
                                            // if acceptance looks too low
}

transformed data {
  real<lower=0> shape_mex = inv_square(cv_mex);
}

generated quantities {
  matrix[S, N_new] x_true_new;
  matrix[S, N_new] y_new_rep;

  for (s in 1:S) {
    real rate_x_s = shape_x_draws[s] / mu_x_draws[s];
    for (n in 1:N_new) {
      real x_s_n = sample_x_true_new_rng(
        x_obs_new[n], shape_x_draws[s], rate_x_s, shape_mex, shape_prop, n_mh_iter
      );
      x_true_new[s, n] = x_s_n;

      real mu_y_s_n = exp(beta0_draws[s] + beta1_draws[s] * log(x_s_n));
      y_new_rep[s, n] = gamma_rng(shape_draws[s], shape_draws[s] / mu_y_s_n);
    }
  }
}
