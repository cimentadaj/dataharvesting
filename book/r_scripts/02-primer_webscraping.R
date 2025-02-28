library(scrapex)
library(rvest)
library(httr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

link <- history_elections_spain_ex()
link


browseURL(prep_browser(link))



set_config(
  user_agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0; Jorge Cimentada / cimentadaj@gmail.com")
)

html_website <- link %>% read_html()
html_website



all_tables <-
  html_website %>%
  html_table()



elections_data <- all_tables[[5]]
elections_data



elections_data %>% select_if(is.character)


wrong_labels <- c(
  "Dissolved",
  "[k]",
  "[l]",
  "[m]",
  "n",
  "Banned",
  "Boycotted",
  "Did not run"
)


wrong_labels <- paste0(wrong_labels, collapse = "|")
wrong_labels


semi_cleaned_data <-
  elections_data %>%
  mutate_if(
    is.character,
    ~ str_replace_all(string = .x, pattern = wrong_labels, replacement = NA_character_)
  )


semi_cleaned_data %>% select_if(is.character)


semi_cleaned_data <-
  semi_cleaned_data %>%
  mutate(
    Election = str_replace_all(string = Election, pattern = "Apr. |Nov. ", replacement = "")
  )


semi_cleaned_data %>% select_if(is.character)


semi_cleaned_data <-
  semi_cleaned_data %>%
  mutate_all(as.numeric) %>%
  filter(!is.na(Election))

semi_cleaned_data


semi_cleaned_data <-
  semi_cleaned_data %>%
  rename_all(~ str_replace_all(.x, "\\[.+\\]", ""))

semi_cleaned_data


# Pivot from wide to long to plot it in ggplot
cleaned_data <-
  semi_cleaned_data %>%
  pivot_longer(-Election, names_to = "parties")

# Plot it
cleaned_data %>%
  ggplot(aes(Election, value, color = parties)) +
  geom_line() +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  scale_color_viridis_d() +
  theme_minimal()


library(scrapex)

aging <- read_html(retirement_age_europe_ex())

aging_europe <-
  aging %>%
  html_table() %>%
  .[[2]]

aging_europe %>%
  select(Country, Men, Women) %>%
  mutate(
    Country,
    Men = as.numeric(str_sub(Men, 1, 2)),
    Women = as.numeric(str_sub(Women, 1, 2))
  ) %>%
  pivot_longer(Men:Women) %>%
  ggplot(aes(reorder(Country, -value), value, color = name)) +
  geom_point() +
  scale_x_discrete(name = "Country") +
  scale_y_continuous(name = "Age at retirement") +
  coord_flip() +
  theme_minimal()


# important_dates <- all_tables[[6]]
# names(important_dates) <- c("type_election", "years")
# 
# all_years <-
#   important_dates %>%
#   filter(type_election == "General elections") %>%
#   pull(years) %>%
#   str_split(pattern = "\n") %>%
#   .[[1]] %>%
#   str_sub(1, 4) %>%
#   as.numeric()
# 
# general_elections <- all_years[!is.na(all_years)]
# general_elections


# important_dates <- all_tables[[6]]
# names(important_dates) <- c("type_election", "years")
# 
# all_years <-
#   important_dates %>%
#   filter(
#     type_election %in% c("General elections", "Local elections", "European elections")
#   ) %>%
#   pull(years) %>%
#   str_split(pattern = "\n") %>%
#   lapply(str_sub, 1, 4) %>%
#   lapply(as.numeric)
# 
# overlapping_years <- intersect(all_years[[1]], intersect(all_years[[2]], all_years[[3]]))
# overlapping_years


