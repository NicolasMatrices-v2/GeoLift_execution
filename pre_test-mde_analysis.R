######################
## Install packages ##
######################
# install.packages("devtools")
# library(devtools)
# install_github("ArturoEsquerra/GeoLift", force=TRUE)
# install.packages("glue")
# install.packages("ggplot2")

###################
## Load packages ##
###################

suppressPackageStartupMessages(library(GeoLift))
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(ggplot2))

import::here("lift_power_aggregation", "plot_power_curve", .from="aux_functions.R")
import::here("TREATMENT_START", "TREATMENT_LOCATIONS", 
             "KPI", "Q_DAYS_LOOKBACK_POWER", .from="cfg.R")
import::here("extract_transform_data", .from="extract_transform.R")

#####################
## Import dataset ##
#####################

transformed_data_list <- extract_transform_data(
  kpi = KPI, 
  q_days_lookback_power = Q_DAYS_LOOKBACK_POWER)
geolift_data <- transformed_data_list$geolift_data
pre_test_geolift_data <- transformed_data_list$pre_test_geolift_data
TREATMENT_DURATION <- transformed_data_list$TREATMENT_DURATION
MIN_TRAINING_PERIOD <- transformed_data_list$MIN_TRAINING_PERIOD

###############################
##   Get MDE for Treatment   ##
###############################

print('...Calculating power & MDE...')
results_power <- GeoLiftPower(
  pre_test_geolift_data,
  locations = TREATMENT_LOCATIONS,
  effect_size = seq(-1, 1, 0.01),
  treatment_periods = TREATMENT_DURATION,
  horizon = MIN_TRAINING_PERIOD,
  Y_id = "Y",
  location_id = "location",
  time_id = "time",
  cpic = 50)

power_agg_list <- lift_power_aggregation(results_power)
print(glue("Positive MDE is {power_agg_list$positive_mde * 100} %"))
print(glue("Negative MDE is {power_agg_list$negative_mde * 100} %"))

###############################
##  Exploratory power plot   ##
###############################

plot_power_curve(
  agg_power_results = power_agg_list$agg_power_results,
  power_mde = power_agg_list$positive_mde,
  days_looked_at = power_agg_list$days_looked_at,
  treatment_duration = TREATMENT_DURATION,
  treatment_locations = TREATMENT_LOCATIONS,
  font_size=10)
