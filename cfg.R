##############################
## Set working dir & Params ##
##############################

# Local dirs
# Note: here (and henceforth) we assume the working dir is this current file's
# directory
CURR_DIR <- getwd()
IN_DIR <- file.path(CURR_DIR, "panel_data")

# TEST CONSTANTS
FILE_NAME <- "MMMMMM.csv"
KPI <- "conversions"
TREATMENT_LOCATIONS <- c("aaaaaa")
TREATMENT_START <- "2020-01-02"
TREATMENT_END <- "2020-03-02"

# SETUP CONSTANTS
TEST_DURATIONS <- c(15, 30)
# This constant represents the amount of days that will be taken into account to analyze power.
Q_DAYS_LOOKBACK_POWER <- 15
SIGNIFICANCE_LVL <- 0.1
FIXED_EFFECTS <- TRUE
EFFECT_RANGE <- seq(-1, 1, 0.01)
