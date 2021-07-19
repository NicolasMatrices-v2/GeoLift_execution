suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(glue))

lift_power_aggregation <- function(
  results_power
){
  DAYS_LOOKED_AT <- max(results_power$treatment_start) - min(results_power$treatment_start)
  agg_power_results <- results_power %>% group_by(lift) %>% summarize(
    average_imbalance = mean(ScaledL2Imbalance),
    average_power = mean(pow))
  
  POSITIVE_MDE <- agg_power_results[
    head(which(agg_power_results$average_power > 0.8 & 
                 agg_power_results$lift > 0), 1), 
    "lift"][[1]]
  NEGATIVE_MDE <- agg_power_results[
    tail(which(agg_power_results$average_power > 0.8 & 
                 agg_power_results$lift < 0), 1), 
    "lift"][[1]]
  return(list(agg_power_results = agg_power_results, 
              positive_mde = POSITIVE_MDE,
              negative_mde = NEGATIVE_MDE,
              days_looked_at = DAYS_LOOKED_AT))
}

plot_power_curve <- function(
  agg_power_results,
  power_mde,
  days_looked_at,
  treatment_duration,
  treatment_locations,
  font_size=15
){
  ggplot(agg_power_results, aes(x=lift, y=average_power)) + 
  geom_line(color = "salmon") +
  theme_minimal() +
  labs(x="Effect Size",
       y="Average Power",
       title="Power curve for treatment",
       subtitle=glue(
         "Analyzing past {days_looked_at} days before treatment of {treatment_duration} days"
       ),
       caption=glue("Treatment group: ({treatment_locations})")
  ) +
  scale_x_continuous(labels = scales::percent) +
  scale_y_continuous(labels = scales::percent, limits=c(0,1)) +
  geom_hline(yintercept=0.8, linetype="dashed", alpha=0.2) +
  geom_vline(xintercept=power_mde, linetype="dashed", alpha=1, color="#00AFBB") +
  geom_text(x=data.frame(c = rep(power_mde, nrow(agg_power_results)))$c - 0.04, 
            label=glue("MDE: \n{power_mde*100} %"), 
            y=0.1, 
            colour="#00AFBB",
            angle=90, 
            vjust = 1,
            size=3) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        text = element_text(size=font_size))
}
