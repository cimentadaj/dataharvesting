library(xml2)
library(httr)
library(tidyverse)
library(sf)
library(rnaturalearth)
library(scrapex)


## -------------------------------------------------------------------------------------------------------------------
school_links <- spanish_schools_ex()

# Keep only the HTML file of one particular school.
school_url <- school_links[13]


browseURL(prep_browser(school_url))

school_raw <- read_html(school_url) %>% xml_child()
school_raw

location_str <-
  school_raw %>%
  xml_find_all("//p[@class='d-flex align-items-baseline g-mt-5']//a") %>%
  xml_attr(attr = "href")


location <-
  location_str %>%
  str_extract_all("=.+$")

location


location <-
  location %>%
  str_replace_all("=|colegio\\.longitud", "")

location


location <-
  location %>%
  str_split("&") %>%
  .[[1]]

location


# This sets your `User-Agent` globally so that all requests are identified with this `User-Agent`
set_config(
  user_agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0; Jorge Cimentada / cimentadaj@gmail.com")
)

# Collapse all of the code from above into one function called
# school grabber

school_grabber <- function(school_url) {
  # We add a time sleep of 5 seconds to avoid
  # sending too many quick requests to the website
  Sys.sleep(2)

  school_raw <- read_html(school_url) %>% xml_child()

  location_str <-
    school_raw %>%
    xml_find_all("//p[@class='d-flex align-items-baseline g-mt-5']//a") %>%
    xml_attr(attr = "href")

  location <-
    location_str %>%
    str_extract_all("=.+$") %>%
    str_replace_all("=|colegio\\.longitud", "") %>%
    str_split("&") %>%
    .[[1]]

  # Turn into a data frame
  data.frame(
    latitude = location[1],
    longitude = location[2],
    stringsAsFactors = FALSE
  )
}

school_grabber(school_url)

x <- c()
for (i in 1:10) {
  x <- c(x, i + 1)
}

adder <- function(x) x + 1
map_dbl(1:10, adder)

coordinates <- map_dfr(school_links, school_grabber)
coordinates


coordinates <- data.frame(
    latitude = c(42.727787, 43.2443899, 38.9559234, 39.1865665, 40.382453,
                 40.2292912, 40.4385997, 40.3351393, 40.5054637, 40.6382608,
                 40.3854323, 37.7648471, 38.8274492, 40.994337, 40.994337,
                 40.5603732, 40.994337, 40.994337, 41.1359296, 41.2615548, 41.2285137,
                 41.1458017, 41.183406, 42.0781977, 42.2524468, 41.7376665,
                 41.623449),
   longitude = c(-8.6567935, -8.8921645, -1.2255769, -1.6225903, -3.6410388,
                 -3.1106322, -3.6970366, -3.5155669, -3.3738441, -3.4537107,
                 -3.66395, -1.5030467, 0.0221681, -5.6224391, -5.6224391,
                 -5.6703725, -5.6224391, -5.6224391, 0.9901905, 1.1670507, 0.5461471,
                 0.8199749, 0.5680564, 1.8203155, 1.8621546, 1.8383666, 2.0013628)
)

coordinates


coordinates <- mutate_all(coordinates, as.numeric)

sp_sf <-
  ne_countries(scale = "large", country = "Spain", returnclass = "sf") %>%
  st_transform(crs = 4326)

ggplot(sp_sf) +
  geom_sf() +
  geom_point(data = coordinates, aes(x = longitude, y = latitude)) +
  coord_sf(xlim = c(-20, 10), ylim = c(25, 45)) +
  theme_minimal() +
  ggtitle("Sample of schools in Spain")


school_raw %>%
  xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']")


text_boxes <-
  school_raw %>%
  xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']//strong") %>%
  xml_text()


single_public_private <-
  text_boxes %>%
  str_detect("Centro") %>%
  text_boxes[.]

single_public_private


grab_public_private_school <- function(school_link) {
  ## Sys.sleep(5)
  school <- read_html(school_link)
  text_boxes <-
    school %>%
    xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']//strong") %>%
    xml_text()

  single_public_private <-
    text_boxes %>%
    str_detect("Centro") %>%
    text_boxes[.]


  data.frame(
    public_private = single_public_private,
    stringsAsFactors = FALSE
  )
}

public_private_schools <-
  map_dfr(school_links, grab_public_private_school)

public_private_schools



# Let's translate the public/private names from Spanish to English
lookup <- c("Centro Público" = "Public", "Centro Privado" = "Private")
public_private_schools$public_private <- lookup[public_private_schools$public_private]

# Merge it with the coordinates data
all_schools <- cbind(coordinates, public_private_schools)

# Plot private/public by coordinates
ggplot(sp_sf) +
  geom_sf() +
  geom_point(data = all_schools, aes(x = longitude, y = latitude, color = public_private)) +
  coord_sf(xlim = c(-20, 10), ylim = c(25, 45)) +
  theme_minimal() +
  ggtitle("Sample of schools in Spain by private/public")


text_boxes <-
  school_raw %>%
  xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']")

text_boxes


selected_node <- text_boxes %>% xml_text() %>% str_detect("Tipo Centro")
selected_node


single_type_school <-
  text_boxes[selected_node] %>%
  xml_find_all(".//strong") %>%
  xml_text()

single_type_school


grab_type_school <- function(school_link) {
  ## Sys.sleep(5)
  school <- read_html(school_link)

  text_boxes <-
    school %>%
    xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']")

  selected_node <-
    text_boxes %>%
    xml_text() %>%
    str_detect("Tipo Centro")

  single_type_school <-
    text_boxes[selected_node] %>%
    xml_find_all(".//strong") %>%
    xml_text()


  data.frame(
    type_school = single_type_school,
    stringsAsFactors = FALSE
  )
}

all_type_schools <- map_dfr(school_links, grab_type_school)
all_type_schools

all_schools <- cbind(all_schools, all_type_schools)

ggplot(sp_sf) +
  geom_sf() +
  geom_point(data = all_schools, aes(x = longitude, y = latitude, color = public_private)) +
  coord_sf(xlim = c(-20, 10), ylim = c(25, 45)) +
  facet_wrap(~ type_school) +
  theme_minimal() +
  ggtitle("Sample of schools in Spain")


all_mode_schools <-
  school_links %>%
  lapply(function(x) {
      x %>%
        read_html() %>%
        xml_find_all("//table[@class='table table-striped']//tbody//tr//td[4]") %>%
        xml_text() %>%
        unique()
  }) %>%
  as.character()

mode_schools <- data.frame(mode_school = all_mode_schools)
head(mode_schools)


amenities <-
  school_links %>%
  lapply(function(x) {
    x %>%
      read_html() %>%
      xml_find_all("//section[@id='pkg-servicios']//p[@class='mb-0']") %>%
      xml_text() %>%
      paste(collapse = ", ")
  }) %>%
  as.character() %>%
  ifelse(. == "", NA, .)

amenities <- data.frame(amenities = amenities)
amenities[11:16, , drop = FALSE]


addresses <-
  school_links %>%
  lapply(function(x) {
    x %>%
      read_html() %>%
      xml_find_all("//ul[@class='list-unstyled mb-0']") %>%
      xml_children() %>%
      xml_text() %>%
      str_replace_all("\\r|\\n", "") %>%
      str_trim() %>%
      paste0(collapse = ", ")
  }) %>%
  as.character()

addresses <- data.frame(addresses = addresses)
head(addresses)


href_data <-
  school_links %>%
  lapply(function(x) {
    all_href <-
      x %>%
      read_html() %>%
      xml_find_all("//section[@id='otros-colegios']//div[@class='row no-gutters']") %>%
      xml_find_all(".//h3[@class='text-uppercase g-font-weight-700 g-font-size-22 g-mb-25']") %>%
      xml_children() %>%
      xml_attr("href")

    href_df <- data.frame(
      school_one = all_href[1],
      school_two = all_href[2],
      school_three = all_href[3],
      school_four = all_href[4]
    )

    href_df
  }) %>%
  do.call(rbind, .)

as_tibble(href_data)


final_df <- as_tibble(cbind(all_schools, mode_schools, amenities, addresses, href_data))
final_df



library(scrapex)
res <- api_amazon()


list(
  api_endpoint = "http://localhost:1624/api/v1/amazon/books?author=Cameron%20Gutkowski&genre=Ad",
  headers = c("Authorization bearer: Asdwe21213xS")
)

library(scrapex)
library(httr2)
library(dplyr)
library(ggplot2)

api_web <- paste0(api_covid$api_web, "/api/v1/covid_cases")
cases_endpoint <- paste0(api_web, "?region=California&sex=m")

api_web <- paste0(api_covid$api_web, "/api/v1/covid_cases")

resp_body_california_m <-
  api_web %>%
  request() %>%
  req_url_query(region = "California", sex = "m") %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()


options(scipen = 231241231)

resp_body_california_m <-
  resp_body_california_m %>%
  mutate(Date = lubridate::ymd(Date)) %>%
  group_by(Date, Sex) %>%
  summarize(cases = sum(Value))

resp_body_california_m %>%
  ggplot(aes(Date, cases)) +
  geom_line() +
  theme_bw()
