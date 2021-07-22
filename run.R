# File runs the actual GeoLift for a certain Treatment group, KPI and Treatment start and end dates.

######################
## Install packages ##
######################
# install.packages("devtools")
# library(devtools)
# install_github("ArturoEsquerra/GeoLift", force=TRUE)
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("glue")
# install.packages("import")

###################
## Load packages ##
###################

suppressPackageStartupMessages(library(GeoLift))
suppressPackageStartupMessages(library(dplyr))
import::here("extract_transform_data", .from="extract_transform.R")
import::here("TREATMENT_START", "TREATMENT_LOCATIONS", "KPI", .from="cfg.R")

#####################
## Import dataset ##
#####################

transformed_data_list <- extract_transform_data(kpi = KPI)
geolift_data <- transformed_data_list$geolift_data
date_vector <- transformed_data_list$date_vector
ACTUAL_TREATMENT_END <- transformed_data_list$ACTUAL_TREATMENT_END

#######################
## Descriptive stats ##
#######################

df_locations <- geolift_data %>%
  group_by(location) %>%
  summarize(amount = sum(Y), .groups = "drop") %>%
  arrange(desc(amount)) %>%
  ungroup() %>%
  mutate(conversion_share = 100 * amount/sum(amount),
         conversion_share_accum = cumsum(conversion_share),
         location = factor(location, levels = .data$location)) %>%
  arrange(desc(conversion_share_accum))

# See how KPI evolves throughout time per location.
GeoPlot(geolift_data)
# See how KPI is concentrated per location based on the data.
tail(df_locations, 10)

###############################
## Run GeoLift for Treatment ##
###############################

# Run GeoLift
geo_output <- GeoLift(
  Y_id = "Y",
  data = geolift_data,
  locations = TREATMENT_LOCATIONS,
  treatment_start_time = which(date_vector == TREATMENT_START),
  treatment_end_time = which(date_vector == ACTUAL_TREATMENT_END))

# Get more details from GeoLift results.
## Test stats (estimator, %lift, incremental & pvalue).
## Balance Stats (scaled L2 imbalance, %improvement from naive model).
## Model weeights (what were the weights per location to build synthetic control).
summary(geo_output)

###############################0.
##  Exploratory result plots ##
###############################

# Shows evolution of Treatment and synthetic Control, throughout time.
plot(geo_output, type="Lift")

# Shows evolution of Treatment and synthetic Control difference, throughout time.
plot(geo_output, type="ATT")
