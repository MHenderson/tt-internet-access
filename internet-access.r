library(tigris)
library(janitor)
library(dplyr)
library(ggplot2)
library(readr)

kentucky_counties <- counties(state = "KY") %>%
  clean_names()

broadband <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-11/broadband.csv')

broadband <- broadband %>%
  clean_names() %>%
  mutate(
    usage = as.numeric(broadband_usage),
    avail = as.numeric(broadband_availability_per_fcc)
  )

broadband_ky <- broadband %>%
  filter(st == "KY")

X <- kentucky_counties %>%
  left_join(broadband_ky, by = c("namelsad" = "county_name"))

X %>%
  ggplot() +
  geom_sf(aes(fill = usage)) +
  theme_void() +
  theme(legend.position = "top")

X %>%
  ggplot() +
  geom_sf(aes(fill = avail)) +
  scale_fill_gradient(low = "white", high = "blue") +
  theme_void() +
  theme(legend.position = "top")
