# design-simexp-simplex.R
# 
# design simulation experiments with 3d-simplex-distributed variables
# clay + silt + sand = 1



# -------------------------------------------------------------------------

# parameters of the scenario's:
# should match the arguments of the function sim_data_simplex()
#   sample_size
#   

scenario_labeller_simplex <- function(df) {
  df %>% 
    mutate(
      sample_size_label     = paste0("Nsample", sample_size), 
      
    )
}

# experimental parameters for simexp9: sample_size & 
simexp_design9 <- expand_grid(
  sample_size     = c(100, 200, 500),
  
) %>% scenario_labeller_simplex()






