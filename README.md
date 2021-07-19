# GeoLift execution

The idea of this repository is to provide an easy and simple process to execute GeoLift.

- The GeoLift package is extracted from [this repository](https://github.com/ArturoEsquerra/GeoLift).  Refer to this repository's vignette to understand how to select the best setup possible.

## Steps to run:
1. Clone the repository onto your computer.

2. Set the working directory to the place where you downloaded this repository. Use `setwd("place/where/repo/lives")`.

3. Save the data for the test under the `panel_data/` folder.

4. Edit the cfg.R file.
This holds all the constants for your test.

    - If you have ran a test and know the details for it (Test constants):
      - `FILE_NAME` should be the name of the file that holds the panel data for all locations per time period.
      - `KPI` should be the name of the column that holds all conversion data.
      - `TREATMENT_LOCATIONS` should be a vector holding all treatment group locations, in lower case.
      - `TREATMENT_START` should be the date in which your test started.
      - `TREATMENT_END` should be the date in which your test ended.
  
    - If you have not run a test and are looking for the best setup (Setup constants).
      - `TEST_DURATIONS` holds the different potential durations of the experiment.
      - `Q_DAYS_LOOKBACK_POWER` captures the amount of days that will be used to run different simulations.
      - `EFFECT_RANGE` gets all the different effects that will be simulated over each of the treatment groups.

## Use cases

- If you would like to run a test, use the `run.R` module.
- If you would like to find the MDE you had over the test you ran, before running it, use the `pre_test-mde_analysis.R`.
- If you would like to find the best GeoLift to setup, use `setup.R`.
