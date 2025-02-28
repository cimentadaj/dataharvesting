library(RSelenium)
library(tidyverse)
library(xml2)

# sudo docker run -d -p 4449:4444 -p 5901:5900 selenium/standalone-firefox-debug:2.53.0
# sudo apt-get install vinagre

remDr <- remoteDriver(port = 4449L)
remDr$open()

blog_link <- "https://statmodeling.stat.columbia.edu/"
remDr$navigate(blog_link)

remDr$findElement(
  value = "(//h1[@class='entry-title']//a)[1]"
)$clickElement()

page_source <- remDr$getPageSource()[[1]]

html_code <-
  page_source %>%
  read_html()

categories_first_post <-
  html_code %>%
  xml_find_all("//footer[@class='entry-meta']//a[contains(@href, 'category')]") %>%
  xml_text()

categories_first_post

entry_date <-
  html_code %>%
  xml_find_all("//time[@class='entry-date']") %>%
  xml_text() %>%
  parse_date_time("%B %d, %Y %I:%M %p")

entry_date

final_res <- tibble(entry_date = entry_date, categories = list(categories_first_post))
final_res

remDr$goBack()

source_code <- remDr$getPageSource()[[1]]

collect_categories <- function(page_source) {
  # Read source code of blog post
  html_code <-
    page_source %>%
    read_html()

  # Extract categories
  categories_first_post <-
    html_code %>%
    xml_find_all("//footer[@class='entry-meta']//a[contains(@href, 'category')]") %>%
    xml_text()

  # Extract entry date
  entry_date <-
    html_code %>%
    xml_find_all("//time[@class='entry-date']") %>%
    xml_text() %>%
    parse_date_time("%B %d, %Y %I:%M %p")

  # Collect everything in a data frame
  final_res <- tibble(entry_date = entry_date, categories = list(categories_first_post))
  final_res
}

# Get all number of blog posts on this page
num_blogs <-
  source_code %>%
  read_html() %>%
  xml_find_all("//h1[@class='entry-title']//a") %>%
  length()

blog_posts <- list()

# Loop over each post, extract the categories and go back to the main page
for (i in seq_len(num_blogs)) {
  print(i)
  # Go to the next blog post
  xpath <- paste0("(//h1[@class='entry-title']//a)[", i, "]")
  Sys.sleep(2)
  remDr$findElement(value = xpath)$clickElement()

  # Get the source code
  page_source <- remDr$getPageSource()[[1]]

  # Grab all categories
  blog_posts[[i]] <- collect_categories(page_source)

  # Go back to the main page before next iteration
  remDr$goBack()
}

combined_df <- bind_rows(blog_posts)

combined_df %>%
  unnest(categories) %>%
  count(categories) %>%
  arrange(-n)


remDr$findElement(value = "(//h1[@class='entry-title']//a)[1]")$clickElement()

remDr$findElement(using = "id", "author")

remDr$findElement(using = "id", "author")$sendKeysToElement(list("Data Harvesting Bot"))

remDr$findElement(using = "id", "email")$sendKeysToElement(list("fake-email@gmail.com"))

remDr$refresh()

# Open Vinagre and go to VNc in protocol Input the IP as
# 127.0.0.1:5901 and connect. Password is secret. You should see the browser
# at this point.
