library(tigris)
library(janitor)
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)

kentucky_counties <- counties(state = "KY") %>%
  clean_names()

broadband <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-11/broadband.csv')

broadband <- broadband %>%
  clean_names() %>%
  rename(
    avail = broadband_availability_per_fcc,
    usage = broadband_usage
  ) %>%
  mutate(
    usage = as.numeric(usage),
    avail = as.numeric(avail)
  )

broadband_ky <- broadband %>%
  filter(st == "KY") %>%
  pivot_longer(avail:usage, names_to = "var")

ky_counties_broadband <- kentucky_counties %>%
  left_join(broadband_ky, by = c("namelsad" = "county_name"))

ky_counties_broadband %>%
  ggplot() +
  geom_sf(aes(fill = value)) +
  scale_fill_viridis_c() +
  facet_wrap(~var) +
  theme_void() +
  theme(legend.position = "bottom")
