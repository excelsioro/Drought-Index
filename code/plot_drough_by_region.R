#!/usr/bin/env Rscript

library(tidyverse)
library(glue)
library(lubridate)
prcp_data <- read_tsv("/mnt/c/Users/js199/OneDrive/Desktop/Drought-Index/data/ghcnd_tidy.tsv.gz")

station_data <- read_tsv("/mnt/c/Users/js199/OneDrive/Desktop/Drought-Index/data/ghcnd_regions_years.tsv")



#this_year <- lat_long_prcp %>%
 # filter(year == 2022) %>%
  #select(-year)

#inner_join(lat_long_prcp, this_year, by = c("latitude", "longitude")) %>%
 # rename(all_years = mean_prcp.x,
  #       this_year = mean_prcp.y) %>%

#prcp_data <- read_tsv("C:/Users/js199/OneDrive/Desktop/Drought-Index/data/ghcnd_tidy.tsv.gz")

#station_data <- read_tsv("C:/Users/js199/OneDrive/Desktop/Drought-Index/data/ghcnd_regions_years.tsv")

end = format(today(), "%B %d")
start = format(today() - 30, "%B %d")


lat_long_prcp <- inner_join(prcp_data, station_data, by = "id") %>%
  filter((year != first_year & year != last_year) | year == 2022) %>% 
  group_by(latitude, longitude, year) %>%
  summarize(mean_prcp = mean(prcp), .groups = "drop")


lat_long_prcp %>%
  group_by(latitude, longitude) %>%
  mutate(z_score = (mean_prcp - mean(mean_prcp)) / sd(mean_prcp),
         n = n()) %>%
  ungroup() %>%
  filter(n >= 50 & year == 2022) %>%
  select(-n, -mean_prcp, -year) %>%
  mutate(z_score = if_else(z_score > 2, 2, z_score),
         z_score = if_else(z_score < -2, -2, z_score)) %>%
  ggplot(aes(x= longitude, y = latitude, fill = z_score)) +
        geom_tile() +
        coord_fixed() +
        scale_fill_gradient2(low = "#fc8d59", mid = "#ffffbf", high = "#67a9cf", midpoint = 0,
        breaks = c(-2, -1, 0, 1, 2),
        labels = c("<-2", "-1", "0", "1", ">2")) +
        theme(plot.background = element_rect(fill = "black", color = "black"), 
        panel.background = element_rect(fill = "black"), 
        plot.title = element_text(color = "#ffffbf", size = 18),
        plot.subtitle = element_text(color = "#ffffbf"),
        plot.caption = element_text(color = "#ffffbf"),
        panel.grid = element_blank(),
        legend.background = element_blank(), 
        legend.text = element_text(color = "#ffffbf"), 
        legend.position = c(0.15,0), 
        legend.direction = "horizontal", 
        legend.key.height = unit(0.25, "cm"),
        axis.text = element_blank()) +
   labs(title = glue("Amount of Precipitation for {start} to {end}"), 
        subtitle = "Standardized Z-Scores for the Past 50 Years", 
        caption = "Precipitation Data Collected from GHCN Daily Data at NOAA")
  

#ggsave("C:/Users/js199/OneDrive/Desktop/Drought-Index/visuals/world_drought.png")

ggsave("/mnt/c/Users/js199/OneDrive/Desktop/Drought-Index/visuals/world_drought.png", width = 8, height = 4)
