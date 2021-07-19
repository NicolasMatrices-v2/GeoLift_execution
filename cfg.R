##############################
## Set working dir & Params ##
##############################

# RADIO TEST CONSTANTS
IN_DIR <- "/home/nicocru/geolift_uala/panel_data"
FILE_NAME <- "MMMMMM.csv"
KPI <- "conversions"
TREATMENT_LOCATIONS <- "AAAAAA"
TREATMENT_START <- "2020-01-02"
TREATMENT_END <- "2020-03-02"

# SETUP CONSTANTS
TEST_DURATIONS <- c(15, 30)
# This constant represents the amount of days that will be taken into account to analyze power.
Q_DAYS_LOOKBACK_POWER <- 15
SIGNIFICANCE_LVL <- 0.1
FIXED_EFFECTS <- TRUE
EFFECT_RANGE <- seq(-1, 1, 0.01)
