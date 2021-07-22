# File extracts the data from panel_data dir, preprocesses it and transforms it into GeoLift input format.

######################
## Install packages ##
######################
# install.packages("devtools")
# library(devtools)
# install_github("ArturoEsquerra/GeoLift", force=TRUE)
# install.packages("dplyr")
# install.packages("import")

###################
## Load packages ##
###################

suppressPackageStartupMessages(library(dplyr))

import::here("GeoDataRead", .from="GeoLift")
import::here("IN_DIR", "FILE_NAME", "KPI", "TREATMENT_LOCATIONS", "TREATMENT_START", "TREATMENT_END",
             "Q_DAYS_LOOKBACK_POWER", .from = "cfg.R")

#########################
## Pre-process dataset ##
#########################

extract_transform_data <- function(
  in_dir = IN_DIR, file_name = FILE_NAME, kpi = KPI, 
  treatment_start = TREATMENT_START, treatment_end = TREATMENT_END,
  q_days_lookback_power = Q_DAYS_LOOKBACK_POWER){
  data_dump <- read.csv(file.path(in_dir, file_name))
  
  # Keep only dates that are before test ends.
  data_dump <- data_dump[data_dump$creation_date <= treatment_end, ]
  # We exclude the last date because data is not complete.
  data_dump <- data_dump[data_dump$creation_date < max(data_dump$creation_date), ]
  # We exclude empty state because it doesn't make sense.
  data_dump <- data_dump[data_dump$state != "", ]
  # Drop rows were values are zero.
  data_dump <- data_dump[data_dump[kpi] > 0, ]
  
  date_vector <- sort(unique(data_dump$creation_date))
  ACTUAL_TREATMENT_END <- ifelse(
    treatment_end %in% date_vector,
    treatment_end,
    max(date_vector)
  )
  TREATMENT_DURATION <- which(date_vector == ACTUAL_TREATMENT_END) - which(date_vector == treatment_start)
  MIN_TRAINING_PERIOD <- which(date_vector == treatment_start) - TREATMENT_DURATION - q_days_lookback_power
  
  geolift_data <- GeoDataRead(
    data_dump,
    date_id = "creation_date", 
    location_id = 'state',
    Y_id = kpi,
    format = "yyyy-mm-dd")
  
  pre_test_geolift_data <- geolift_data[
    geolift_data$time < which(date_vector == treatment_start), ]
  
  return(list(
    geolift_data = geolift_data, 
    pre_test_geolift_data = pre_test_geolift_data,
    date_vector = date_vector,
    ACTUAL_TREATMENT_END = ACTUAL_TREATMENT_END,
    TREATMENT_DURATION = TREATMENT_DURATION,
    MIN_TRAINING_PERIOD = MIN_TRAINING_PERIOD))
}
