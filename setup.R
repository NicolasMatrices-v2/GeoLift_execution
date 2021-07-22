# File finds what the best treatment group and test duration for a certain country and dataset is.

######################
## Install packages ##
######################
# install.packages("devtools")
# library(devtools)
# install_github("ArturoEsquerra/GeoLift", force=TRUE)
# install.packages("dplyr")

###################
## Load packages ##
###################

suppressPackageStartupMessages(library(GeoLift))
suppressPackageStartupMessages(library(dplyr))

import::here("TEST_DURATIONS", "KPI", "Q_DAYS_LOOKBACK_POWER",
             "SIGNIFICANCE_LVL", "FIXED_EFFECTS", "EFFECT_RANGE", .from="cfg.R")
import::here("extract_transform_data", .from="extract_transform.R")
import::here("lift_power_aggregation", "plot_power_curve", .from="aux_functions.R")

#####################
## Import dataset ##
#####################

transformed_data_list <- extract_transform_data(
  kpi = KPI, 
  q_days_lookback_power = Q_DAYS_LOOKBACK_POWER)
pre_test_geolift_data <- transformed_data_list$pre_test_geolift_data
MIN_TRAINING_PERIOD <- transformed_data_list$MIN_TRAINING_PERIOD
total_locations <- length(unique(pre_test_geolift_data$location))
Q_LOCATIONS <- seq(4, floor(total_locations / 2), 1)

#########################################
##   Search for treatments w/0 effect  ##
##         GeoLiftPower.search         ##
#########################################
# Calculate share of times in which a certain treatment does not detect an effect
# when the true effect is zero.
# Locations in treatment groups are randomly sampled.

resultsSearch <- suppressWarnings(GeoLiftPower.search(
  data = pre_test_geolift_data,
  treatment_periods = TEST_DURATIONS,
  N = Q_LOCATIONS,
  horizon = MIN_TRAINING_PERIOD,
  Y_id = "Y",
  location_id = "location",
  time_id = "time",
  top_results = 0,
  alpha = SIGNIFICANCE_LVL,
  type = "pValue",
  fixed_effects = FIXED_EFFECTS,
  ProgressBar = TRUE,
  run_stochastic_process = TRUE))

head(resultsSearch %>% arrange(mean_scaled_l2_imbalance), 5)
head(resultsSearch)

#########################################
##   Find best guess MDE per treatment ##
##        GeoLiftPowerFinder           ##
#########################################
# Apply range of effects to last date before simulation.
# Determine if estimated effect had a confidence > 90%.
# Return MDE.

resultsFind <- GeoLiftPowerFinder(data = pre_test_geolift_data,
                                  treatment_periods = TEST_DURATIONS,
                                  N = Q_LOCATIONS,
                                  Y_id = "Y",
                                  location_id = "location",
                                  time_id = "time",
                                  effect_size = EFFECT_RANGE[EFFECT_RANGE > 0],
                                  top_results = 0,
                                  alpha = SIGNIFICANCE_LVL,
                                  fixed_effects = FIXED_EFFECTS,
                                  ProgressBar = TRUE,
                                  plot_best = FALSE,
                                  run_stochastic_process = TRUE)
head(resultsFind)
head(resultsFind[resultsFind$ProportionTotal_Y > 0.15, ] %>% 
       arrange(ScaledL2Imbalance, MinDetectableEffect)
)

##############################################
##   Find actual MDE for specific treatment ##
##              GeoLiftPower                ##
##############################################

# Print results from Search and Find.
head(resultsSearch %>% arrange(mean_scaled_l2_imbalance), 5)
head(resultsSearch)
head(resultsFind[resultsFind$ProportionTotal_Y > 0.15, ] %>% 
       arrange(ScaledL2Imbalance, MinDetectableEffect)
)
head(resultsFind)

nrank <- 30#1 # Decide ranked row to select.
use_df <- resultsFind#resultsSearch # Decide dataset to use
TREATMENT_LOCATIONS <- stringr::str_split(use_df[use_df$rank == nrank,]$location, ", ")[[1]]
duration_of_test <- use_df[use_df$rank == nrank,]$duration[[1]]
duration_of_test <- ifelse(
  is.null(duration_of_test), sample(TEST_DURATIONS, 1), duration_of_test)

MIN_TRAINING_PERIOD <- max(pre_test_geolift_data$time) - duration_of_test - Q_DAYS_LOOKBACK_POWER

results_power <- GeoLiftPower(
  pre_test_geolift_data,
  locations = TREATMENT_LOCATIONS,
  effect_size = EFFECT_RANGE,
  treatment_periods = duration_of_test,
  horizon = MIN_TRAINING_PERIOD,
  Y_id = "Y",
  location_id = "location",
  time_id = "time",
  cpic = 20)

power_agg_list <- lift_power_aggregation(results_power)
print(glue("Positive MDE is {power_agg_list$positive_mde * 100} %"))
print(glue("Negative MDE is {power_agg_list$negative_mde * 100} %"))

###############################
##  Exploratory power plot   ##
###############################

plot_power_curve(
  agg_power_results = power_agg_list$agg_power_results,
  power_mde = power_agg_list$positive_mde,
  q_days_lookback_power = Q_DAYS_LOOKBACK_POWER,
  treatment_duration = duration_of_test,
  treatment_locations = TREATMENT_LOCATIONS,
  font_size=10)
