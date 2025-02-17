library(targets)

tar_option_set(
  packages = c("dplyr", "ggplot2", "janitor", "ragg", "readr", "scales", "tidyr", "tigris")
)

list(
  tar_target(
       name = ky_counties,
    command = counties(state = "KY") |> clean_names()
  ),
  tar_target(
       name = broadband,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-11/broadband.csv')
  ),
  tar_target(
       name = broadband_clean,
    command = {
      broadband |>
        clean_names() |>
        rename(
          Availability = broadband_availability_per_fcc,
                 Usage = broadband_usage
        ) |>
        mutate(
                 Usage = as.numeric(Usage),
          Availability = as.numeric(Availability)
        )
    }
  ),
  tar_target(
       name = broadband_ky,
    command = broadband_clean |>
      filter(st == "KY") |>
      pivot_longer(Availability:Usage, names_to = "var")
  ),
  tar_target(
       name = ky_counties_broadband,
    command = ky_counties |>
      left_join(broadband_ky, by = c("namelsad" = "county_name"))
  ),
  tar_target(
       name = dat_text,
    command = {
      dat_text <- data.frame(
        label = c(
          "Have access to fixed terrestrial broadband\nas of end of 2017.*",
          "Use the internet at broadband speeds\nas of November 2019.**"
        ),
        var  = c("Availability", "Usage"),
        x = c(-91, -91),
        y = c(38.5, 38.5)
      )
    }
  ),
  tar_target(
       name = main_plot,
    command = {

      base_size <- 12
      font1 <- "Cardo"
      background_colour <- "#eff2f7"
      text_colour <- "#10192d"

      ky_counties_broadband |>
      ggplot() +
      geom_sf(aes(fill = value), size = .2) +
      scale_fill_viridis_c(labels = percent, option = "cividis") +
      facet_wrap(~var, ncol = 1) +
      geom_text(data = dat_text, aes(x = x, y = y, label = label, family = font1, size = base_size, hjust = 0), show.legend = FALSE) +
      theme_void() +
      theme(legend.position = "bottom") +
      labs(
        title = "Internet Access in Kentucky",
        subtitle = "Data: Microsoft/FCC | Graphic: Matthew Henderson",
        caption = "*https://www.fcc.gov/document/broadband-deployment-report-digital-divide-narrowing-substantially-0\n**https://github.com/microsoft/USBroadbandUsagePercentages"
      ) +
      theme(
        plot.margin       = margin(t = 20, r = 15, b = 20, l = 15, unit = "pt"),
        panel.background  = element_rect(fill = background_colour, colour = NA),
        plot.background   = element_rect(fill = background_colour, colour = NA),
        legend.background = element_rect(colour = background_colour, fill = background_colour),
        strip.background  = element_rect(colour = background_colour, fill = background_colour),
        plot.title        = element_text(colour = text_colour, size = 26, hjust = 1, family = font1, margin = margin(5, 0, 20, 0)),
        plot.subtitle     = element_text(colour = text_colour, size = base_size, hjust = 1, family = font1, margin = margin(5, 0, 10, 0)),
        plot.caption      = element_text(colour = text_colour, size = 10, hjust = 0, family = font1),
        legend.title      = element_blank(),
        legend.text       = element_text(family = font1),
     legend.justification = "right",
        legend.margin     = margin(0, 0, 0, 0),
        legend.box.margin = margin(t = 15, r = 15, b = 0, l = 0, unit = "pt"),
        strip.text        = element_blank(),
        legend.position   = "bottom",
        legend.key.width  = unit(1, 'cm'),
        axis.title.x      = element_blank(),
        axis.title.y      = element_blank(),
        axis.text.x       = element_blank(),
        axis.text.y       = element_blank(),
        axis.ticks.x      = element_blank(),
        axis.ticks.y      = element_blank(),
        panel.grid.major  = element_blank(),
        panel.grid.minor  = element_blank(),
      )    
    }
  ),
  tar_target(
       name = save_main_plot,
    command = {
      agg_png("plot/internet-access.png", res = 300, height = 7.7, width = 7, units = "in")
      print(main_plot)
      dev.off()
    } 
  )
)
