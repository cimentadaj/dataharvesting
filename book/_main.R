## ----primer-setup, include=FALSE----------------------------------------------
main_dir <- "./images/primer_webscraping"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

knitr::knit_hooks$set(purl = knitr::hook_purl)


## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elections_plot.png"))

## -----------------------------------------------------------------------------
library(scrapex)
library(rvest)
library(httr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

link <- history_elections_spain_ex()
link

## ---- eval = FALSE------------------------------------------------------------
#  browseURL(prep_browser(link))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elections_website.png"))

## -----------------------------------------------------------------------------
set_config(
  user_agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0; Jorge Cimentada / cimentadaj@gmail.com")
)

html_website <- link %>% read_html()
html_website

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elections_table.png"))

## -----------------------------------------------------------------------------
all_tables <-
  html_website %>%
  html_table()

## -----------------------------------------------------------------------------
elections_data <- all_tables[[5]]
elections_data

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elections_table.png"))

## -----------------------------------------------------------------------------
elections_data %>% select_if(is.character)

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
wrong_labels <- paste0(wrong_labels, collapse = "|")
wrong_labels

## -----------------------------------------------------------------------------
semi_cleaned_data <-
  elections_data %>%
  mutate_if(
    is.character,
    ~ str_replace_all(string = .x, pattern = wrong_labels, replacement = NA_character_)
  )

## -----------------------------------------------------------------------------
semi_cleaned_data %>% select_if(is.character)

## -----------------------------------------------------------------------------
semi_cleaned_data <-
  semi_cleaned_data %>%
  mutate(
    Election = str_replace_all(string = Election, pattern = "Apr. |Nov. ", replacement = "")
  )

## -----------------------------------------------------------------------------
semi_cleaned_data %>% select_if(is.character)

## -----------------------------------------------------------------------------
semi_cleaned_data <-
  semi_cleaned_data %>%
  mutate_all(as.numeric) %>%
  filter(!is.na(Election))

semi_cleaned_data

## -----------------------------------------------------------------------------
semi_cleaned_data <-
  semi_cleaned_data %>%
  rename_all(~ str_replace_all(.x, "\\[.+\\]", ""))

semi_cleaned_data

## -----------------------------------------------------------------------------
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

## ---- echo = FALSE------------------------------------------------------------
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

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  important_dates <- all_tables[[6]]
#  names(important_dates) <- c("type_election", "years")
#  
#  all_years <-
#    important_dates %>%
#    filter(type_election == "General elections") %>%
#    pull(years) %>%
#    str_split(pattern = "\n") %>%
#    .[[1]] %>%
#    str_sub(1, 4) %>%
#    as.numeric()
#  
#  general_elections <- all_years[!is.na(all_years)]
#  general_elections

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  important_dates <- all_tables[[6]]
#  names(important_dates) <- c("type_election", "years")
#  
#  all_years <-
#    important_dates %>%
#    filter(
#      type_election %in% c("General elections", "Local elections", "European elections")
#    ) %>%
#    pull(years) %>%
#    str_split(pattern = "\n") %>%
#    lapply(str_sub, 1, 4) %>%
#    lapply(as.numeric)
#  
#  overlapping_years <- intersect(all_years[[1]], intersect(all_years[[2]], all_years[[3]]))
#  overlapping_years

## ----data-formats-setup, include=FALSE----------------------------------------
main_dir <- "./images/data_formats"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## ---- message = FALSE---------------------------------------------------------
library(xml2)

## -----------------------------------------------------------------------------
xml_test <- "<people>
<jason>
  <person type='fictional'>
    <first_name>
      <married>
        Jason
      </married>
    </first_name>
    <last_name>
        Bourne
    </last_name>
    <occupation>
      Spy
    </occupation>
  </person>
</jason>
<carol>
  <person type='real'>
    <first_name>
      <married>
        Carol
      </married>
    </first_name>
    <last_name>
        Kalp
    </last_name>
    <occupation>
      Scientist
    </occupation>
  </person>
</carol>
</people>
"

cat(xml_test)

## ---- out.width = "30%", echo = FALSE-----------------------------------------
knitr::include_graphics(file.path(main_dir, "examples/xml_one.png"))

## ---- out.width = "30%", echo = FALSE-----------------------------------------
knitr::include_graphics(file.path(main_dir, "examples/xml_two.png"))

## ---- out.width = "30%", echo = FALSE-----------------------------------------
knitr::include_graphics(file.path(main_dir, "examples/xml_three.png"))

## -----------------------------------------------------------------------------
html_test <- "<html>
  <head>
    <title>Div Align Attribbute</title>
  </head>
  <body>
    <div align='left'>
      First text
    </div>
    <div align='right'>
      Second text
    </div>
    <div align='center'>
      Third text
    </div>
    <div align='justify'>
      Fourth text
    </div>
  </body>
</html>
"

## ---- echo = FALSE------------------------------------------------------------
knitr::include_graphics(file.path(main_dir, "examples/html_ex1.png"))

## ---- out.width = "100%", echo = FALSE----------------------------------------
knitr::include_graphics(file.path(main_dir, "examples/html_ex2.jpg"))

## -----------------------------------------------------------------------------
xml_raw <- read_xml(xml_test)
xml_structure(xml_raw)

## -----------------------------------------------------------------------------
# xml_child returns only one child (specified in search)
# Here, jason is the first child
xml_child(xml_raw, search = 1)

# Here, carol is the second child
xml_child(xml_raw, search = 2)

# Use xml_children to extract **all** children
child_xml <- xml_children(xml_raw)

child_xml

## -----------------------------------------------------------------------------
# Extract the attribute type from all nodes
xml_attrs(child_xml, "type")

## -----------------------------------------------------------------------------
child_xml

## -----------------------------------------------------------------------------
# We go down one level of children
person_nodes <- xml_children(child_xml)

# <person> is now the main node, so we can extract attributes
person_nodes

# Both type attributes
xml_attrs(person_nodes, "type")

## -----------------------------------------------------------------------------
# Specific address of each person tag for the whole xml tree
# only using the `person_nodes`
xml_path(person_nodes)

## -----------------------------------------------------------------------------
# You can use results from xml_path like directories
xml_find_all(xml_raw, "/people/jason/person")

## -----------------------------------------------------------------------------
html_raw <- read_html(html_test)
html_structure(html_raw)

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  div_nodes <- xml_child(html_raw, search = 2)
#  xml_attrs(xml_children(div_nodes), "align")

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  carol_node <- xml_child(xml_raw, search = 2)
#  person_node <- xml_child(carol_node, search = 1)
#  occupation <- xml_child(person_node, search = 3)
#  xml_text(occupation)

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  div_nodes <- xml_child(html_raw, search = 2)
#  xml_text(xml_children(div_nodes), "align")

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  custom_xml <- "<root>
#  <child1 family='1'>
#  <granchild1>
#  </granchild1>
#  <granchild2>
#  </granchild2>
#  </child1>
#  
#  
#  <child2>
#  <granchild1>
#  </granchild1>
#  <granchild2 family='1'>
#  </granchild2>
#  </child2>
#  </root>"
#  
#  custom_raw <- read_xml(custom_xml)
#  
#  # First attribute
#  xml_attrs(xml_find_all(custom_raw, "/root/child1"))
#  
#  # Second attribute
#  xml_attrs(xml_find_all(custom_raw, "/root/child2/granchild2"))

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  xml_list <- as_list(xml_raw)
#  xml_list$people$carol$person$last_name[[1]]

## ----intro-regex, include=FALSE-----------------------------------------------
main_dir <- "./images/intro_regex"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## -----------------------------------------------------------------------------
library(stringr)
library(scrapex)
library(rvest)
library(xml2)
library(lubridate)
library(vistime)
library(tibble)

## -----------------------------------------------------------------------------
borges <- "I like hourglasses, maps, eighteenth century typography."
str_view_all(borges, "eighteenth", match = TRUE)

## -----------------------------------------------------------------------------
str_replace_all(borges, "eighteenth", "[DATE]")

## -----------------------------------------------------------------------------
str_extract_all(borges, "eighteenth")

## -----------------------------------------------------------------------------
borges <- "I like hourglasses, maps, eighteenth Eighteenth century typography."
str_view_all(borges, ".ighteenth", match = TRUE)

## -----------------------------------------------------------------------------
borges <- "I like hourglasses, maps, ighteenth century typography."
str_view_all(borges, ".ighteenth", match = TRUE)

## -----------------------------------------------------------------------------
borges_two_phrase <- c(
  "I like hourglasses, maps, eighteenth century typography.",
  "I like hourglasses, maps, seventeenth century typography."
)

str_view_all(borges_two_phrase, "maps, . century")

## -----------------------------------------------------------------------------
str_view_all(borges_two_phrase, "maps, .+ century")

## -----------------------------------------------------------------------------
borges <- "I like hourglasses. I also like maps, eighteenth century typography"
str_view_all(borges, "I like .+")

## -----------------------------------------------------------------------------
str_view_all(borges, "I like .+\\.")

## -----------------------------------------------------------------------------
borges_two_phrase <- c(
  "I like hourglasses, maps, eighteenth century typography.",
  "I like hourglasses, maps, seventeenth century typography."
)

res <- str_extract_all(borges_two_phrase, "maps, .+ century")
res

## -----------------------------------------------------------------------------
res %>% str_replace_all("maps, | century", "")

## -----------------------------------------------------------------------------
borges <- "I like hourglasses. I also like maps, eighteenth century typography"
str_view_all(borges, "^.", match = TRUE)

## -----------------------------------------------------------------------------
str_view_all(borges, ".$", match = TRUE)

## -----------------------------------------------------------------------------
borges_long <- c(
  "I like cars. I like hourglasses, maps, eighteenth century typography.",
  "I like computers. I like hourglasses, maps, eighteenth century typography."
)

## -----------------------------------------------------------------------------
str_view_all(borges_long, "^I like .+")

## -----------------------------------------------------------------------------
str_view_all(borges_long, "^I like .+\\.")

## -----------------------------------------------------------------------------
str_view_all(borges, " ")

## -----------------------------------------------------------------------------
str_replace_all(borges, "\\s", "")

## -----------------------------------------------------------------------------
gdp <- c(
  "Afghanistan 516 US dollars",
  "Albania 6494 US dollars",
  "Algeria 3765 US dollars",
  "American Samoa 12844 US dollars",
  "Andorra 43047 US dollars"
)

## -----------------------------------------------------------------------------
str_view_all("Angel is 8 years old", "\\d")

## -----------------------------------------------------------------------------
str_view_all(
  c("Angel is 8 years old", "Martha is 56 years old"),
  "\\d"
)

## -----------------------------------------------------------------------------
str_view_all(
  c("Angel is 8 years old", "Martha is 56 years old"),
  "\\d+"
)

## -----------------------------------------------------------------------------
gdp_chr <- str_extract_all(gdp, "\\d+")
lapply(gdp_chr, as.numeric)

## -----------------------------------------------------------------------------
retirement <-
  # Read in our scrapex example with retirement ages
  retirement_age_europe_ex() %>%
  read_html() %>%
  html_table() %>%
  .[[2]]

retirement

## -----------------------------------------------------------------------------
str_view_all(retirement$Men, "6[789]")

## -----------------------------------------------------------------------------
str_view_all(retirement$Men, "6[7-9]")

## -----------------------------------------------------------------------------
str_view_all(retirement$Men, "6[^5-9]")

## -----------------------------------------------------------------------------
history_france_html <- history_france_ex()
history_france <- read_html(history_france_html)

## ---- eval = FALSE------------------------------------------------------------
#  browseURL(prep_browser(history_france_html))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "history_fr_main.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "kings_timeline_wk.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "kings_timeline_wk_developertools.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "kings_timeline_wk_dev.png"))

## -----------------------------------------------------------------------------
history_france %>%
  xml_find_all("//ul[.//a[contains(@title, 'House of Valois')]]")

## -----------------------------------------------------------------------------
all_txt <-
  history_france %>%
  xml_find_all("//ul[.//a[contains(@title, 'House of Valois')]][2]") %>%
  xml_text()

all_txt

## -----------------------------------------------------------------------------
all_txt <-
  all_txt %>%
  str_split("\n") %>%
  .[[1]]

all_txt

## -----------------------------------------------------------------------------
all_txt <- all_txt[!str_detect(all_txt, "^House")]
all_txt

## -----------------------------------------------------------------------------
all_txt[7]

## -----------------------------------------------------------------------------
all_txt <-
  all_txt %>%
  str_replace_all(pattern = "\\(.+\\)", replacement = "")

all_txt

## -----------------------------------------------------------------------------
res <-
  all_txt %>%
  str_extract_all("\\d+")

res

## -----------------------------------------------------------------------------
convert_time_period <- function(x) {
  start_year <- x[1]
  end_year <- x[2]
  # If end year has only 2 digits
  if (nchar(end_year) == 2) {
    # Extract the first two years from the start year
    end_year_prefix <- str_sub(start_year, 1, 2)
    # Paste together the correct year for the end year
    end_year <- paste0(end_year_prefix, end_year)
  }
  # Replace correct end year
  x[2] <- end_year
  as.numeric(x)
}

## -----------------------------------------------------------------------------
sequence_kings <- lapply(res, convert_time_period)
sequence_kings

## -----------------------------------------------------------------------------
all_txt %>%
  str_extract("^.+,")

## -----------------------------------------------------------------------------
names_kings <-
  all_txt %>%
  str_extract("^.+,") %>%
  str_replace_all(",", "")

names_kings

## -----------------------------------------------------------------------------
# Combine into data frames
sequence_kings_df <- lapply(sequence_kings, function(x) data.frame(start = x[1], end = x[2]))
final_kings <- do.call(rbind, sequence_kings_df)

# Add king names
final_kings$event <- names_kings
final_kings$start <- make_date(final_kings$start, 1, 1)
final_kings$end <- make_date(final_kings$end, 1, 1)

# Final data frame
final_kings <- as_tibble(final_kings)
final_kings

## -----------------------------------------------------------------------------
gg_vistime(final_kings, col.group = "event", show_labels = FALSE)

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "kings_timeline_wk_earlier_period.png"))

## ---- echo = FALSE------------------------------------------------------------
history_france_html <- history_france_ex()
history_france <- read_html(history_france_html)

all_txt <-
  history_france %>%
  xml_find_all("//ul[.//a[contains(@title, 'House of Valois')]][1]") %>%
  xml_text() %>%
  str_split("\n") %>%
  .[[1]]

all_txt <- all_txt[!str_detect(all_txt, "House")]
all_txt <- all_txt[str_detect(all_txt, "\\d+")]

res <-
  all_txt %>%
  str_extract_all("\\d+")


convert_time_period <- function(x) {
  if (length(x) == 1) {
    start_year <- x[1]
    end_year <- x[1]
  } else {
    start_year <- x[1]
    end_year <- x[2]
  }

  # If end year has only 2 digits
  if (nchar(end_year) == 2) {
    # Extract the first two years from the start year
    end_year_prefix <- str_sub(start_year, 1, 2)
    # Paste together the correct year for the end year
    end_year <- paste0(end_year_prefix, end_year)
  }
  # Replace correct end year
  x[2] <- end_year
  as.numeric(x)
}

sequence_kings <- lapply(res, convert_time_period)

names_kings <-
  all_txt %>%
  str_extract("^.+,") %>%
  str_replace_all(",", "")

# Combine into data frames
sequence_kings_df <- lapply(sequence_kings, function(x) data.frame(start = x[1], end = x[2]))
final_kings_earlier <- do.call(rbind, sequence_kings_df)

# Add king names
final_kings_earlier$event <- names_kings
final_kings_earlier$start <- make_date(final_kings_earlier$start, 1, 1)
final_kings_earlier$end <- make_date(final_kings_earlier$end, 1, 1)

# Final data frame
final_kings_earlier <- as_tibble(final_kings_earlier)

# Merge with earlier results
final_kings_total <- rbind(final_kings_earlier, final_kings)

# Plot
gg_vistime(final_kings_total, col.group = "event", show_labels = FALSE)

## -----------------------------------------------------------------------------
text <- "I like hourglasses. I also like maps, eighteenth century typography."
str_extract_all(text, "I like .+\\.")[[1]]

## ---- echo = FALSE------------------------------------------------------------
str_extract_all(text, "I like .+?\\.")[[1]]

## ---- echo = FALSE------------------------------------------------------------
history_france_html <- history_france_ex()
history_france <- read_html(history_france_html)

history_france %>%
  xml_text() %>%
  str_extract_all("House of .+?\\s") %>%
  .[[1]] %>%
  str_trim() %>%
  str_replace_all("[:punct:]", "") %>%
  unique()

## ----xpath-setup, include=FALSE-----------------------------------------------
main_dir <- "./images/xpath"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## -----------------------------------------------------------------------------
library(xml2)
library(magrittr)
library(scrapex)

## -----------------------------------------------------------------------------
raw_xml <- "
<bookshelf>
  <dansimmons>
    <book>
      Hyperion Cantos
    </book>
  </dansimmons>
</bookshelf>"

book_xml <- read_xml(raw_xml)
direct_address <- "/bookshelf/dansimmons/book"

book_xml %>%
  xml_find_all(direct_address)

## -----------------------------------------------------------------------------
# Note the new `<authors>` tag, a child of `<bookshelf>`.
raw_xml <- "
<bookshelf>
  <authors>
    <dansimmons>
      <book>
        Hyperion Cantos
      </book>
    </dansimmons>
  </authors>
</bookshelf>"

book_xml <- raw_xml %>% read_xml()

book_xml %>%
  xml_find_all(direct_address)

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons")

## -----------------------------------------------------------------------------
# Note the new `<release_year>` tag below the second (also new) `<book>` tag
raw_xml <- "
<bookshelf>
  <authors>
    <dansimmons>
      <book>
        Hyperion Cantos
      </book>
      <book>
        <release_year>
         1996
        </release_year>
        Endymion
      </book>
    </dansimmons>
  </authors>
</bookshelf>"

book_xml <- raw_xml %>% read_xml()

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons/book")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons/release_year")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons//release_year")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons//release_year") %>%
  xml_path()

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons/book[2]")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons/book[8]")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons/*")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("/*/*/*/book")

## -----------------------------------------------------------------------------
# Note the new <stephenking> tag with it's book 'The Stand' and all <book> tags have some attributes
raw_xml <- "
<bookshelf>
  <authors>
    <dansimmons>
      <book price='yes' topic='scifi'>
        Hyperion Cantos
      </book>
      <book topic='scifi'>
        <release_year>
         1996
        </release_year>
        Endymion
      </book>
    </dansimmons>
    <stephenking>
    <book price='yes' topic='horror'>
     The Stand
    </book>
    </stephenking>
  </authors>
</bookshelf>"

book_xml <- raw_xml %>% read_xml()

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//dansimmons//book[@price='yes']") %>%
  xml_text()

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//book[@price='yes' and @topic='horror']") %>%
  xml_text()

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//book[@price]")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//book[@price!='yes']")

## -----------------------------------------------------------------------------
book_xml %>%
  xml_find_all("//book[@price='yes' or @topic='scifi']") %>%
  xml_text()

## -----------------------------------------------------------------------------
newspaper_link <- elpais_newspaper_ex()
newspaper <- read_html(newspaper_link)

## ---- eval = FALSE------------------------------------------------------------
#  browseURL(prep_browser(newspaper_link))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elpais_main.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elpais_science_main.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elpais_science_main_sourcecode.png"))

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section//a[contains(@href, 'science')]")

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "elpais_science_main_sourcecode.png"))

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section/*/*/a[contains(@href, 'science')]")

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section/*/*/a[contains(text(), 'Science, Tech & Health')]") %>%
  xml_attr("href")

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section//a[contains(text(), 'Science, Tech & Health')]") %>%
  xml_attr("href")

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section/*/*/a[not(contains(text(), 'Science, Tech & Health'))]") %>%
  xml_attr("href")

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section[count(.//article)>3]")

## -----------------------------------------------------------------------------
newspaper %>%
  xml_find_all("//section[count(.//article)>3]") %>%
  xml_attr("data-dtm-region")

## ---- eval = FALSE------------------------------------------------------------
#  # Find all sections
#  newspaper %>%
#    xml_find_all("//section")
#  
#  # Return all divs below all sections
#  newspaper %>%
#    xml_find_all("//section//div")
#  
#  # Return all sections which a div as a child
#  newspaper %>%
#    xml_find_all("//section/div")
#  
#  # Return the child (any, because of *) of all sections
#  newspaper %>%
#    xml_find_all("//section/*")
#  
#  # Return all a tags of all section tags which have two nodes in between
#  newspaper %>%
#    xml_find_all("//section/*/*/a")
#  
#  # Return all a tags below all section tags without a class attribute
#  newspaper %>%
#    xml_find_all("//section//a[not(@class)]")
#  
#  # Return all a tags below all section tags that contain a class attribute
#  newspaper %>%
#    xml_find_all("//section//a[@class]")
#  
#  # Return all a tags of all section tags which have two nodes in between
#  # and contain some text in the a tag.
#  newspaper %>%
#    xml_find_all("//section/*/*/a[contains(text(), 'Science')]")
#  
#  # Return all span tags in the document with a specific class
#  newspaper %>%
#    xml_find_all("//span[@class='c_a_l']")
#  
#  # Return all span tags in the document that don't have a specific class
#  newspaper %>%
#    xml_find_all("//span[@class!='c_a_l']")
#  
#  # Return all a tags where an attribute starts with something
#  newspaper %>%
#    xml_find_all("//a[starts-with(@href, 'https://')]")
#  
#  # Return all a tags where an attribute contains some text
#  newspaper %>%
#    xml_find_all("//a[contains(@href, 'science-tech')]")
#  
#  # Return all section tags which have tag *descendants (because of the .//)* that have a class attribute
#  newspaper %>%
#    xml_find_all("//section[.//a[@class]]")
#  
#  # Return all section tags which have <td> children
#  newspaper %>%
#    xml_find_all("//section[td]")
#  
#  # Return the first occurrence of a section tag
#  newspaper %>%
#    xml_find_all("(//section)[1]")
#  
#  # Return the last occurrence of a section tag
#  newspaper %>%
#    xml_find_all("(//section)[last()]")

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  newspaper %>%
#    xml_find_all("//img[contains(@src, 'jpg')]") %>%
#    length()
#  
#  newspaper %>%
#    xml_find_all("//img[contains(@src, 'png')]") %>%
#    length()

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  newspaper %>%
#    xml_find_all("//article") %>%
#    length()

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  newspaper %>%
#    xml_find_all("//h2[@class='c_t ']/a[contains(text(), 'climate')]")

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  library(stringr)
#  newspaper %>%
#    xml_find_all("//span[@class='c_a_l']") %>%
#    xml_text() %>%
#    # Some cities are combined together with , or /
#    str_split(pattern = ",|/") %>%
#    unlist() %>%
#    # Remove all spaces before/after the city for counting properly
#    trimws() %>%
#    table()

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "description_text.png"))

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  art_p <-
#    newspaper %>%
#    # Grab only the articles that have a p tag *below* each article.
#    # p tags are for paragraphs and contains the description of a file
#    xml_find_all("//article[.//p]")
#  
#  lengthy_art <-
#    art_p %>%
#    xml_text() %>%
#    nchar() %>%
#    which.max()
#  
#  art_p[lengthy_art] %>%
#    xml_find_all(".//h2/a") %>%
#    xml_text()

## ----knitr-setup, include=FALSE-----------------------------------------------
main_dir <- "./images/cs_spanish_school_locations"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)


## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "/automatic_rmarkdown/spain-map-schools-1.png"))

## ---- message = FALSE---------------------------------------------------------
library(xml2)
library(httr)
library(tidyverse)
library(sf)
library(rnaturalearth)
library(scrapex)

## -----------------------------------------------------------------------------
school_links <- spanish_schools_ex()

# Keep only the HTML file of one particular school.
school_url <- school_links[13]

school_url

## ---- eval = FALSE------------------------------------------------------------
#  browseURL(prep_browser(school_url))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/main_website_no_selection.png"))

## -----------------------------------------------------------------------------
school_raw <- read_html(school_url) %>% xml_child()
school_raw

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/developer_tools.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/main_page.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/search_developer_tools.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/location_tag.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/location_tag_zoomed.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/father_p_tag.png"))

## ---- echo = FALSE------------------------------------------------------------
library(ggdag)
set.seed(51231)
confounder_triangle(x = "<a> tag", y = "<i> tag", z = "<p> tag") %>%
  ggdag(use_labels = "label") +
  theme_dag()

## -----------------------------------------------------------------------------
# Search for all <p> tags with that class in the document
school_raw %>%
  xml_find_all("//p[@class='d-flex align-items-baseline g-mt-5']")

## -----------------------------------------------------------------------------

school_raw %>%
  xml_find_all("//p[@class='d-flex align-items-baseline g-mt-5']//a")


## -----------------------------------------------------------------------------
location_str <-
  school_raw %>%
  xml_find_all("//p[@class='d-flex align-items-baseline g-mt-5']//a") %>%
  xml_attr(attr = "href")

location_str

## -----------------------------------------------------------------------------
location <-
  location_str %>%
  str_extract_all("=.+$")

location

## -----------------------------------------------------------------------------
location <-
  location %>%
  str_replace_all("=|colegio\\.longitud", "")

location

## -----------------------------------------------------------------------------
location <-
  location %>%
  str_split("&") %>%
  .[[1]]

location

## -----------------------------------------------------------------------------
# This sets your `User-Agent` globally so that all requests are identified with this `User-Agent`
set_config(
  user_agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0; Jorge Cimentada / cimentadaj@gmail.com")
)

# Collapse all of the code from above into one function called
# school grabber

school_grabber <- function(school_url) {
  # We add a time sleep of 5 seconds to avoid
  # sending too many quick requests to the website
  Sys.sleep(5)

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

## ---- eval = FALSE------------------------------------------------------------
#  coordinates <- map_dfr(school_links, school_grabber)
#  coordinates

## ---- echo = FALSE------------------------------------------------------------
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

## ---- spain-map-schools-------------------------------------------------------
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

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/main_website_public_private.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/tag_public_private.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/father_tag_public_private.png"))

## -----------------------------------------------------------------------------
school_raw %>%
  xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']")

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/main_website_details_box.png"))

## -----------------------------------------------------------------------------
text_boxes <-
  school_raw %>%
  xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']//strong") %>%
  xml_text()

text_boxes

## -----------------------------------------------------------------------------
single_public_private <-
  text_boxes %>%
  str_detect("Centro") %>%
  text_boxes[.]

single_public_private

## ---- eval = FALSE------------------------------------------------------------
#  grab_public_private_school <- function(school_link) {
#    Sys.sleep(5)
#    school <- read_html(school_link)
#    text_boxes <-
#      school %>%
#      xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']//strong") %>%
#      xml_text()
#  
#    single_public_private <-
#      text_boxes %>%
#      str_detect("Centro") %>%
#      text_boxes[.]
#  
#  
#    data.frame(
#      public_private = single_public_private,
#      stringsAsFactors = FALSE
#    )
#  }
#  
#  public_private_schools <- map_dfr(school_links, grab_public_private_school)
#  public_private_schools

## ---- echo = FALSE------------------------------------------------------------
grab_public_private_school <- function(school_link) {
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

public_private_schools <- map_dfr(school_links, grab_public_private_school)
public_private_schools

## -----------------------------------------------------------------------------
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

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/main_website_type_school.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/main_website_type_school_header.png"))

## -----------------------------------------------------------------------------
text_boxes <-
  school_raw %>%
  xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']")

text_boxes

## -----------------------------------------------------------------------------
selected_node <- text_boxes %>% xml_text() %>% str_detect("Tipo Centro")
selected_node

## -----------------------------------------------------------------------------
single_type_school <-
  text_boxes[selected_node] %>%
  xml_find_all(".//strong") %>%
  xml_text()

single_type_school

## ---- eval = FALSE------------------------------------------------------------
#  grab_type_school <- function(school_link) {
#    Sys.sleep(5)
#    school <- read_html(school_link)
#  
#    text_boxes <-
#      school %>%
#      xml_find_all("//div[@class='col-6 g-brd-left g-brd-bottom g-theme-brd-gray-light-v3 g-px-15 g-py-25']")
#  
#    selected_node <-
#      text_boxes %>%
#      xml_text() %>%
#      str_detect("Tipo Centro")
#  
#    single_type_school <-
#      text_boxes[selected_node] %>%
#      xml_find_all(".//strong") %>%
#      xml_text()
#  
#  
#    data.frame(
#      type_school = single_type_school,
#      stringsAsFactors = FALSE
#    )
#  }
#  
#  all_type_schools <- map_dfr(school_links, grab_type_school)
#  all_type_schools

## ---- echo = FALSE------------------------------------------------------------
grab_type_school <- function(school_link) {
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

## -----------------------------------------------------------------------------
all_schools <- cbind(all_schools, all_type_schools)

ggplot(sp_sf) +
  geom_sf() +
  geom_point(data = all_schools, aes(x = longitude, y = latitude, color = public_private)) +
  coord_sf(xlim = c(-20, 10), ylim = c(25, 45)) +
  facet_wrap(~ type_school) +
  theme_minimal() +
  ggtitle("Sample of schools in Spain")

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/school_modality.png"))

## ---- echo = FALSE------------------------------------------------------------
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

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/services_school.png"))

## ---- echo = FALSE------------------------------------------------------------
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

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/school_address_selection.png"))

## ---- echo = FALSE------------------------------------------------------------
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

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "buscocolegios_xml/other_schools_href.png"))

## ---- echo = FALSE------------------------------------------------------------
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

## ---- echo = FALSE------------------------------------------------------------
final_df <- as_tibble(cbind(all_schools, mode_schools, amenities, addresses, href_data))
final_df

## ----automating-setup, include=FALSE------------------------------------------
main_dir <- "./images/automating_scripts"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)


## -----------------------------------------------------------------------------
# Load all our libraries
library(scrapex)
library(xml2)
library(magrittr)
library(purrr)
library(tibble)
library(tidyr)
library(readr)

# If this were being done on the real website of the newspaper, you'd want to
# replace the line below with the real link of the website.
newspaper_link <- elpais_newspaper_ex()
newspaper <- read_html(newspaper_link)

all_sections <-
  newspaper %>%
  # Find all <section> tags which have an <article> tag
  # below each <section> tag. Keep only the <article>
  # tags which an attribute @data-dtm-region.
  xml_find_all("//section[.//article][@data-dtm-region]")

final_df <-
  all_sections %>%
  # Count the number of articles for each section
  map(~ length(xml_find_all(.x, ".//article"))) %>%
  # Name all sections
  set_names(all_sections %>% xml_attr("data-dtm-region")) %>%
  # Convert to data frame
  enframe(name = "sections", value = "num_articles") %>%
  unnest(num_articles)

final_df

## ---- eval = FALSE------------------------------------------------------------
#  library(scrapex)
#  library(xml2)
#  library(magrittr)
#  library(purrr)
#  library(tibble)
#  library(tidyr)
#  library(readr)
#  
#  newspaper_link <- elpais_newspaper_ex()
#  
#  all_sections <-
#    newspaper_link %>%
#    read_html() %>%
#    xml_find_all("//section[.//article][@data-dtm-region]")
#  
#  final_df <-
#    all_sections %>%
#    map(~ length(xml_find_all(.x, ".//article"))) %>%
#    set_names(all_sections %>% xml_attr("data-dtm-region")) %>%
#    enframe(name = "sections", value = "num_articles") %>%
#    unnest(num_articles)
#  
#  # Save the current date time as a column
#  final_df$date_saved <- format(Sys.time(), "%Y-%m-%d %H:%M")
#  
#  # Where the CSV will be saved. Note that this directory
#  # doesn't exist yet.
#  file_path <- "~/newspaper/newspaper_section_counter.csv"
#  
#  # *Try* reading the file. If the file doesn't exist, this will silently save an error
#  res <- try(read_csv(file_path, show_col_types = FALSE), silent = TRUE)
#  
#  # If the file doesn't exist
#  if (inherits(res, "try-error")) {
#    # Save the data frame we scraped above
#    print("File doesn't exist; Creating it")
#    write_csv(final_df, file_path)
#  } else {
#    # If the file was read successfully, append the
#    # new rows and save the file again
#    rbind(res, final_df) %>% write_csv(file_path)
#  }

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "basic_terminal_ubuntu.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "create_newspaper_dir.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "cd_newspaper.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "running_scraper_once.png"))

## ---- echo = FALSE, out.width = "80%"-----------------------------------------
knitr::include_graphics(file.path(main_dir, "newspaper_scraping_excel.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "crontab_list.png"))

## ---- echo = FALSE, out.width = "80%"-----------------------------------------
knitr::include_graphics(file.path(main_dir, "crontab_syntax.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "crontab_choose_editor.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "crontab_schedule_file.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "crontab_newspaper_scraper.png"))

## ---- echo = FALSE, out.width = "80%"-----------------------------------------
knitr::include_graphics(file.path(main_dir, "newspaper_results_crontab.png"))

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  unlink("./local/share/Trash/", recursive = TRUE, force = TRUE)
#  # The cron expression is: 0 11 * * 1

## ----selenium-setup, include=FALSE--------------------------------------------
main_dir <- "./images/selenium_javascript"
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  eval = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "ess_data_portal.png"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "list_variables_ess_data_portal.png"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "list_variables_source_code.png"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "list_displayed_same_link.png"))

## ---- eval = TRUE-------------------------------------------------------------
library(RSelenium)
library(scrapex)
library(xml2)
library(magrittr)
library(lubridate)
library(dplyr)
library(tidyr)

blog_link <- gelman_blog_ex()

## ---- echo = FALSE------------------------------------------------------------
#  remDr <- rsDriver(port = 4450L, browser = "firefox")

## -----------------------------------------------------------------------------
#  remDr <- rsDriver(port = 4445L)

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "empty_firefox.png"))

## -----------------------------------------------------------------------------
#  remDr$client$navigate(prep_browser(blog_link))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "selenium_blog_main.png"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "blog_first_entry.png"))

## ---- eval = TRUE-------------------------------------------------------------
blog_link %>%
  read_html() %>%
  xml_find_all("(//h1[@class='entry-title']//a)[1]")

## -----------------------------------------------------------------------------
#  # Since we'll use the client a lot let's save it on a separate object
#  driver <- remDr$client
#  driver$findElement(value = "(//h1[@class='entry-title']//a)[1]")$clickElement()

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "first_entry_main_page.png"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "first_entry_comments.png"))

## -----------------------------------------------------------------------------
#  page_source <- driver$getPageSource()[[1]]

## -----------------------------------------------------------------------------
#  html_code <-
#    page_source %>%
#    read_html()

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "gelman_categories_blog.png"))

## -----------------------------------------------------------------------------
#  categories_first_post <-
#    html_code %>%
#    xml_find_all("//footer[@class='entry-meta']//a[contains(@href, 'category')]") %>%
#    xml_text()
#  
#  categories_first_post

## -----------------------------------------------------------------------------
#  entry_date <-
#    html_code %>%
#    xml_find_all("//time[@class='entry-date']") %>%
#    xml_text() %>%
#    parse_date_time("%B %d, %Y %I:%M %p")
#  
#  entry_date

## -----------------------------------------------------------------------------
#  final_res <- tibble(entry_date = entry_date, categories = list(categories_first_post))
#  final_res

## -----------------------------------------------------------------------------
#  driver$goBack()

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "selenium_blog_main.png"))

## -----------------------------------------------------------------------------
#  collect_categories <- function(page_source) {
#    # Read source code of blog post
#    html_code <-
#      page_source %>%
#      read_html()
#  
#    # Extract categories
#    categories_first_post <-
#      html_code %>%
#      xml_find_all("//footer[@class='entry-meta']//a[contains(@href, 'category')]") %>%
#      xml_text()
#  
#    # Extract entry date
#    entry_date <-
#      html_code %>%
#      xml_find_all("//time[@class='entry-date']") %>%
#      xml_text() %>%
#      parse_date_time("%B %d, %Y %I:%M %p")
#  
#    # Collect everything in a data frame
#    final_res <- tibble(entry_date = entry_date, categories = list(categories_first_post))
#    final_res
#  }
#  
#  # Get all number of blog posts on this page
#  num_blogs <-
#    blog_link %>%
#    read_html() %>%
#    xml_find_all("//h1[@class='entry-title']//a") %>%
#    length()
#  
#  blog_posts <- list()
#  
#  # Loop over each post, extract the categories and go back to the main page
#  for (i in seq_len(num_blogs)) {
#    print(i)
#    # Go to the next blog post
#    xpath <- paste0("(//h1[@class='entry-title']//a)[", i, "]")
#    Sys.sleep(2)
#    driver$findElement(value = xpath)$clickElement()
#  
#    # Get the source code
#    page_source <- driver$getPageSource()[[1]]
#  
#    # Grab all categories
#    blog_posts[[i]] <- collect_categories(page_source)
#  
#    # Go back to the main page before next iteration
#    driver$goBack()
#  }

## -----------------------------------------------------------------------------
#  combined_df <- bind_rows(blog_posts)
#  
#  combined_df %>%
#    unnest(categories) %>%
#    count(categories) %>%
#    arrange(-n)

## -----------------------------------------------------------------------------
#  driver$Navigate("http://somewhere.com")
#  driver$goBack()
#  driver$goForward()
#  driver$refresh()
#  driver$getTitle()
#  driver$getCurrentUrl()
#  driver$getStatus()
#  driver$screenshot(display = TRUE)
#  driver$getAllCookies()
#  driver$deleteCookieNamed("PREF")
#  driver$switchToFrame("string|number|null|WebElement")
#  driver$getWindowHandles()
#  driver$getCurrentWindowHandle()
#  driver$switchToWindow("windowId")

## -----------------------------------------------------------------------------
#  driver$findElement(value = "(//h1[@class='entry-title']//a)[1]")$clickElement()

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "first_entry_comments_form.png"))

## -----------------------------------------------------------------------------
#  driver$findElement(using = "id", "author")

## -----------------------------------------------------------------------------
#  driver$findElement(using = "id", "author")$sendKeysToElement(list("Data Harvesting Bot"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "first_entry_author_filled.png"))

## -----------------------------------------------------------------------------
#  driver$findElement(using = "id", "email")$sendKeysToElement(list("fake-email@gmail.com"))

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "first_entry_email_filled.png"))

## -----------------------------------------------------------------------------
#  driver$findElement(using = "id", "submit")$clickElement()

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "first_entry_click_post.png"))

## -----------------------------------------------------------------------------
#  remDr <- rsDriver(port = 4445L)
#  driver <- remDr$client

## -----------------------------------------------------------------------------
#  driver$navigate("somewebsite.com")
#  driver$refresh()
#  driver$goBack()

## -----------------------------------------------------------------------------
#  # With XPath
#  driver$findElement(value = "(//h1[@class='entry-title']//a)[1]")$clickElement()
#  
#  # Or attribute=value instead of XPath
#  driver$findElement(using = "id", "submit")$clickElement()

## -----------------------------------------------------------------------------
#  driver$getPageSource()[[1]]

## -----------------------------------------------------------------------------
#  # With XPath
#  driver$findElement(value = "(//h1[@class='entry-title']//a)[1]")$sendKeysToElement(list("Data Harvesting Bot"))
#  
#  # With attribut=value
#  driver$findElement(using = "id", "author")$sendKeysToElement(list("Data Harvesting Bot"))

## -----------------------------------------------------------------------------
#  driver$close()
#  remDr$server$stop()

## ---- echo = FALSE, out.width = "100%", eval = TRUE---------------------------
knitr::include_graphics(file.path(main_dir, "older_posts.png"))

## ----ethics-setup, include=FALSE----------------------------------------------
#  main_dir <- "./images/ethics"
#  knitr::opts_chunk$set(
#    echo = TRUE,
#    message = FALSE,
#    warning = FALSE,
#    fig.align = "center",
#    fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
#    fig.asp = 0.618
#  )
#  

## ---- eval = FALSE------------------------------------------------------------
#  library(scrapex)
#  
#  # List of links to make a request
#  school_links <- spanish_schools_ex()
#  
#  # List where we will save the information for each link
#  all_schools <- list()
#  
#  single_school_scraper <- function(single_link) {
#    # Before making a request, sleep 5 seconds
#    Sys.sleep(5)
#  
#    # Perform some scraping
#  }
#  
#  # Loop over each link to make a request
#  for (single_link in school_links) {
#    # Save results in a list
#    all_schools[[single_link]] <- single_school_scraper(single_link)
#  }

## ---- echo = FALSE, out.width = "30%"-----------------------------------------
#  knitr::include_graphics(file.path(main_dir, "google_robots.png"))

## -----------------------------------------------------------------------------
#  library(robotstxt)
#  paths_allowed("https://wikipedia.org")

## -----------------------------------------------------------------------------
#  paths_allowed("https://facebook.com")

## ---- echo = FALSE, out.width = "100%"----------------------------------------
#  knitr::include_graphics(file.path(main_dir, "google_useragent.png"))

## -----------------------------------------------------------------------------
#  library(httr)
#  
#  set_config(
#    user_agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0; Jorge Cimentada / cimentadaj@gmail.com")
#  )

## ----intro-api-setup, echo = FALSE, eval = TRUE-------------------------------
main_dir_api <- "./images/intro_api"

knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir_api, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## ---- eval = FALSE------------------------------------------------------------
#  library(scrapex)
#  res <- api_amazon()

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "main_amazon_docs.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "authors_amazon_docs.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "authorize_amazon.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "authors_amazon_request.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "authors_amazon_request_result.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
#  knitr::include_graphics(file.path(main_dir_api, "no_token_error_json.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "authors_amazon_request_result.png"))

## ---- echo = FALSE------------------------------------------------------------
#  list(
#    endpoint = "http://localhost:28723/api/v1/amazon/authors",
#    headers = c(
#      "Authorization" = "Bearer bRKlzSNd7x",
#      "accept" = "application/json"
#    )
#  )

## ---- echo = FALSE------------------------------------------------------------
#  list(
#    status_code = 200,
#    response_headers = c(
#      "content-encoding" = "gzip",
#      "content-type" = "application/json",
#      "date" = "Sun04 Dec 2022 12:28:38 GMT",
#      "transfer-encoding" = "chunked"
#    ),
#    response_body = list(
#      c(
#        "author" = "Cameron Gutkowski",
#        "genre" = "Ad"
#      ),
#      c(
#        "author" = "Stuart Armstrong",
#        "genre" = "Sunt"
#      ),
#      c(
#        "author" = "Kameron Grimes",
#        "genre" = "Eius"
#      ),
#      c(
#        "author" = "Genoveva Hand",
#        "genre" = "A"
#      ),
#      c(
#        "author" = "Kobe Effertz",
#        "genre" = "Possimus"
#      )
#    )
#  )

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "authors_amazon_request_result.png"))

## ----primer-api, echo = FALSE, eval = TRUE------------------------------------
main_dir_api <- "./images/primer_api"

knitr::opts_chunk$set(
  echo = TRUE,
  eval = TRUE,
  message = TRUE,
  collapse = TRUE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir_api, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)


## ---- message = FALSE, collapse = FALSE---------------------------------------
library(scrapex)
library(httr2)
library(dplyr)
library(ggplot2)

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir_api, "coveragedb_covid_cases_plot.png"))

## -----------------------------------------------------------------------------
api_covid <- api_coveragedb()

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir_api, "coveragedb_docs.png"))

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir_api, "coveragedb_covidcases_endpoint.png"))

## -----------------------------------------------------------------------------
# COVID cases endpoint
api_web <- paste0(api_covid$api_web, "/api/v1/covid_cases")

# Filtering only for males in California
cases_endpoint <- paste0(api_web, "?region=California&sex=m")

cases_endpoint

## -----------------------------------------------------------------------------
# COVID cases endpoint
api_web <- paste0(api_covid$api_web, "/api/v1/covid_cases")
req <- request(api_web)
req

## -----------------------------------------------------------------------------
req_california_m <-
  req %>%
  req_url_query(region = "California", sex = "m")

req_california_m

## -----------------------------------------------------------------------------
req_california_m %>%
  req_auth_basic(username = "fake name", password = "fake password") %>%
  req_retry(max_tries = 3, max_seconds = 5)

## -----------------------------------------------------------------------------
req_california_m

## -----------------------------------------------------------------------------
resp_california_m <- 
  req_california_m %>%
  req_perform()

resp_california_m

## -----------------------------------------------------------------------------
resp_status(resp_california_m)

## -----------------------------------------------------------------------------
resp_content_type(resp_california_m)

## -----------------------------------------------------------------------------
resp_body_california_m <-
  resp_california_m %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp_body_california_m

## -----------------------------------------------------------------------------
# To avoid scientific numbering
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

## -----------------------------------------------------------------------------

# Perform the same request but for females and grab the JSON result
resp_body_california_f <-
  req %>%
  req_url_query(region = "California", sex = 'f') %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

# Add the total number of cases per date for females
resp_body_california_f <-
  resp_body_california_f %>%
  mutate(Date = lubridate::ymd(Date)) %>%
  group_by(Date, Sex) %>%
  summarize(cases = sum(Value))

# Combine the female cases with the male cases
resp_body_california <- bind_rows(resp_body_california_f, resp_body_california_m)

# Visualize both female and male cases
resp_body_california %>%
  ggplot(aes(Date, cases, color = Sex, group = Sex)) +
  geom_line() +
  theme_bw()

## -----------------------------------------------------------------------------
api_covid$process$kill()

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  # COVID cases endpoint
#  api_covid <- api_coveragedb()
#  
#  api_web_m <- paste0(api_covid$api_web, "/api/v1/covid_cases?region=New%20York%20State&sex=m")
#  resp_m <- api_web_m %>% request() %>% req_perform() %>% resp_body_json(simplifyVector = TRUE)
#  
#  api_web_f <- paste0(api_covid$api_web, "/api/v1/covid_cases?region=New%20York%20State&sex=f")
#  resp_f <- api_web_f %>% request() %>% req_perform() %>% resp_body_json(simplifyVector = TRUE)
#  
#  api_covid$process$kill()
#  
#  resp <- bind_rows(resp_f, resp_m)
#  
#  # Add the total number of cases per date for both sexes
#  resp_df <-
#    resp %>%
#    mutate(Date = lubridate::ymd(Date)) %>%
#    group_by(Date, Sex) %>%
#    summarize(cases = sum(Value))
#  
#  # Visualize both female and male cases
#  resp_df %>%
#    ggplot(aes(Date, cases, color = Sex, group = Sex)) +
#    geom_line() +
#    theme_bw()

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  
#  # COVID cases endpoint
#  api_covid <- api_coveragedb()
#  
#  api_web_m <- paste0(api_covid$api_web, "/api/v1/covid_vaccines?region=New%20York%20State&sex=m")
#  resp_m <- api_web_m %>% request() %>% req_perform() %>% resp_body_json(simplifyVector = TRUE)
#  
#  api_web_f <- paste0(api_covid$api_web, "/api/v1/covid_vaccines?region=New%20York%20State&sex=f")
#  resp_f <- api_web_f %>% request() %>% req_perform() %>% resp_body_json(simplifyVector = TRUE)
#  
#  api_covid$process$kill()
#  
#  resp <- bind_rows(resp_f, resp_m)
#  
#  # Add the total number of cases per date for both sexes
#  resp_df <-
#    resp %>%
#    mutate(Date = lubridate::ymd(Date)) %>%
#    filter(Measure == "Vaccination3") %>%
#    group_by(Date, Sex, Measure) %>%
#    summarize(cases = sum(Value))
#  
#  # Visualize both female and male cases
#  resp_df %>%
#    ggplot(aes(Date, cases, color = Sex, group = Sex)) +
#    geom_line() +
#    theme_bw()

## ---- echo = FALSE, eval = TRUE-----------------------------------------------
api_web_m <- paste0(api_covid$api_web, "/api/v1/covid_cases?region=California&sex=m")

api_web_m %>% 
  request() %>%
  req_auth_bearer_token("fake token") %>%
  req_retry(max_tries = 5) %>%
  req_throttle(rate = 2) %>%
  req_timeout(10) %>%
  req_headers("Content-type" = "*/*")

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  # COVID cases endpoint
#  api_covid <- api_coveragedb()
#  
#  api_web_m <- paste0(api_covid$api_web, "/api/v1/covid_vaccines?region=New%20York%20State&sex=p")
#  resp_m <- api_web_m %>% request()%>% req_perform()
#  
#  api_covid$process$kill()

## ----dialogue-computer-setup, echo = FALSE, eval = TRUE-----------------------
main_dir_api <- "./images/dialogue_computer"

knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir_api, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "browser_server.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "browser_server_request.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "browser_server_request.png"))

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  library(httr2)
#  req <- request("https://r-project.org")
#  resp <- req_perform(req)
#  resp

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  # A rate limit is the number of API calls an app or user can make within a given time period. If this limit is exceeded or if CPU or total time limits are exceeded, the app or user may be throttled. API requests made by a throttled user or app will fail. You can circumvent it using system sleeps.

## ----primer-json, echo = FALSE, eval = TRUE-----------------------------------
main_dir_api <- "./images/primer_json"

knitr::opts_chunk$set(
  echo = TRUE,
  eval = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir_api, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)


## -----------------------------------------------------------------------------
library(jsonlite)
library(tibble)
library(tidyr)

## -----------------------------------------------------------------------------
json_str <- '{
  "president": "Parlosi",
  "vicepresident": "Kantos",
  "opposition": "Pitaso"
}'

fromJSON(json_str)

## -----------------------------------------------------------------------------
json_str <- '
{
    "president": [
        {
            "last_name": "Parlosi",
            "party": "Free thinkers",
            "age": 35
        }
    ],
    "vicepresident": [
        {
            "last_name": "Kantos",
            "party": "Free thinkers",
            "age": 52
        }
    ],
    "opposition": [
        {
            "last_name": "Pitaso",
            "party": "Everyone United",
            "age": 45
        }
    ]
}
'

fromJSON(json_str, simplifyDataFrame = TRUE)

## -----------------------------------------------------------------------------

json_str <- '
{
    "president": [
        {
            "last_name": "Parlosi",
            "party": "Free thinkers",
            "age": 35
        },
        {
            "last_name": "Stevensson",
            "party": "Free thinkers"
        }
    ],
    "vicepresident": [
        null
    ],
    "opposition": {
        "last_name": "Pitaso",
        "party": "Everyone United",
        "age": 45
    }
}
'

res <- fromJSON(json_str)
res

## -----------------------------------------------------------------------------
res$opposition <- data.frame(res$opposition)
res

## ---- echo = FALSE------------------------------------------------------------
res %>%
  enframe() %>%
  unnest(value)

## -----------------------------------------------------------------------------
res %>%
  enframe()

## -----------------------------------------------------------------------------
res %>%
  enframe() %>%
  unnest(cols = value)

## -----------------------------------------------------------------------------

json_str <- '
{
    "president": [
        {
            "last_name": "Parlosi",
            "party": "Free thinkers",
            "age": 35
        },
        {
            "last_name": "Stevensson",
            "party": "Free thinkers"
        }
    ],
    "vicepresident": [
        null
    ],
    "opposition": {
        "last_name": "Pitaso",
        "party": "Everyone United",
        "age": 45
    }
}
'

res <- fromJSON(json_str)
res

## ---- error=TRUE--------------------------------------------------------------
res %>%
  enframe() %>%
  unnest(cols = value)

## -----------------------------------------------------------------------------

json_str <- '
{
    "client1": [
        {
            "name": "Kurt Rosenwinkel",
            "device": [
                {
                    "type": "iphone",
                    "location": [
                        {
                            "lat": 213.12,
                            "lon": 43.213
                        }
                    ]
                }
            ]
        }
    ],
    "client2": [
        {
            "name": "YEITUEI",
            "device": [
                {
                    "type": "android",
                    "location": [
                        {
                            "lat": 211.12,
                            "lon": 53.213
                        }
                    ]
                }
            ]
        }
    ]
}
'

res <- fromJSON(json_str)
res

## -----------------------------------------------------------------------------
res$client1

## -----------------------------------------------------------------------------
paste0("Device: ", res$client1$device)

## -----------------------------------------------------------------------------
res$client1$device[[1]]

## -----------------------------------------------------------------------------
lapply(res$client1$device[[1]], class)

## -----------------------------------------------------------------------------
res$client1$device[[1]]$location[[1]]

## -----------------------------------------------------------------------------
res$client1 %>%
  as_tibble() %>%
  unnest(cols = device) %>%
  unnest(cols = location)

## -----------------------------------------------------------------------------
all_res <-
  res %>%
  enframe(name = "client")

all_res

## -----------------------------------------------------------------------------
all_res %>%
  unnest(cols = "value")

## -----------------------------------------------------------------------------
all_res %>%
  unnest(cols = "value") %>%
  unnest(cols = "device")

## -----------------------------------------------------------------------------
all_res %>%
  unnest(cols = "value") %>%
  unnest(cols = "device") %>%
  unnest(cols = "location")

## ---- eval = FALSE------------------------------------------------------------
#  library(jsonlite)
#  
#  json_str <- '
#  {
#    "president": [
#      {
#        "last_name": Parlosi,
#        "party": "Free thinkers",
#        "age": 35,
#      },
#      {
#        "last_name": "Stevensson",
#        party: "Free thinkers"
#      }
#    ,
#    "vicepresident": [null],
#    "opposition" =
#      {
#        "last_name": "Pitaso",
#        "party": "Everyone United",
#        "age": 45
#      }
#  }
#  '
#  
#  fromJSON(json_str)

## -----------------------------------------------------------------------------
json_str <- '
{
    "client1": [
        {
            "name": "Kurt Rosenwinkel",
            "device": [
                {
                    "type": "iphone",
                    "location": [
                        "213.12",
                        "43.213"
                    ]
                }
            ]
        }
    ],
    "client2": [
        {
            "name": "YEITUEI",
            "device": [
                {
                    "type": "android",
                    "location": [
                        213.12,
                        43.213
                    ]
                }
            ]
        }
    ]
}
'

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  # The location number of the first slot were strings. Remove quotes.
#  
#  json_str <- '
#  {
#      "client1": [
#          {
#              "name": "Kurt Rosenwinkel",
#              "device": [
#                  {
#                      "type": "iphone",
#                      "location": [
#                          213.12,
#                          43.213
#                      ]
#                  }
#              ]
#          }
#      ],
#      "client2": [
#          {
#              "name": "YEITUEI",
#              "device": [
#                  {
#                      "type": "android",
#                      "location": [
#                          213.12,
#                          43.213
#                      ]
#                  }
#              ]
#          }
#      ]
#  }
#  '
#  res <- fromJSON(json_str)
#  
#  res %>%
#    enframe(name = "client") %>%
#    unnest(cols = "value") %>%
#    unnest(cols = "device") %>%
#    unnest(cols = "location")

## -----------------------------------------------------------------------------
parsed_json <-
  list(
  list(author = "Cameron Gutkowski", genre = "Ad"),
  list(author = "Stuart Armstrong", genre = "Sunt"),
  list(author = "Kameron Grimes", genre = "Eius"),
  list(author = "Genoveva Hand", genre = "A"),
  list(author = "Kobe Effertz", genre = "Possimus")
)

## ---- echo = FALSE------------------------------------------------------------
library(purrr)

parsed_json %>%
  transpose() %>%
  as_tibble() %>%
  unnest()

## ----spanish-schools, include=FALSE-------------------------------------------
main_dir <- "./images/case_study_api_amazon"
knitr::opts_chunk$set(
  echo = TRUE,
  message = TRUE, 
  collapse = TRUE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)

## ---- message = FALSE---------------------------------------------------------
library(scrapex)
library(httr2)
library(dplyr)

## -----------------------------------------------------------------------------
az_api <- api_amazon()

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "main_amazon_docs.png"))

## -----------------------------------------------------------------------------
token <- amazon_bearer_tokens()
token

## -----------------------------------------------------------------------------
main_api_path <- paste0(az_api$api_web, "/api/v1/amazon/")
header_token <- paste0("Bearer ", token)

req <-
  main_api_path %>%
  request() %>%
  req_headers(Authorization = header_token)

req

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "authors_amazon_docs.png"))

## -----------------------------------------------------------------------------
req_res <-
  req %>%
  req_url_path_append("authors")
  
req_res

## -----------------------------------------------------------------------------
res <-
  req_res %>%
  req_perform()

res

## -----------------------------------------------------------------------------
res %>%
  resp_body_json(simplifyVector = TRUE)

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "books_amazon_docs.png"))

## -----------------------------------------------------------------------------
req_res <-
  req %>%
  req_url_path_append("books") %>%
  req_url_query(author = "Stuart Armstrong", genre = "Sunt")

req_res

## -----------------------------------------------------------------------------
resp <-
  req_res %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp

## -----------------------------------------------------------------------------
resp %>%
  select(-user_id) %>%
  distinct()

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "texts_amazon_docs.png"))

## -----------------------------------------------------------------------------
resp <-
  req %>%
  req_url_path_append("texts") %>%
  req_url_query(author = "Stuart Armstrong") %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp

## -----------------------------------------------------------------------------
resp$content

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "products_users_amazon_docs.png"))

## -----------------------------------------------------------------------------
# TODO: If user_id has been specified in the request, the response must have that exact same user_id.
resp <-
  req %>%
  req_url_path_append("products_users") %>%
  req_url_query(user_id = 319) %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "products_amazon_docs.png"))

## -----------------------------------------------------------------------------
resp <-
  req %>%
  req_url_path_append("products") %>%
  req_url_query(product_id = 74) %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp

## ---- echo = FALSE, out.width = "100%"----------------------------------------
knitr::include_graphics(file.path(main_dir, "users_amazon_docs.png"))

## -----------------------------------------------------------------------------
resp <-
  req %>%
  req_url_path_append("users") %>%
  req_url_query(user_id = 319) %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp

## -----------------------------------------------------------------------------
resp <-
  req %>%
  req_url_path_append("users") %>%
  req_url_query(country = "Germany") %>%
  req_perform() %>%
  resp_body_json(simplifyVector = TRUE) %>%
  as_tibble()

resp

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  main_api_path <- paste0(az_api$api_web, "/api/v1/amazon/")
#  header_token <- paste0("Bearer ", amazon_bearer_tokens())
#  
#  # Loop through all authors, extract books and count user_ids.
#  req <-
#    main_api_path %>%
#    request() %>%
#    req_headers(Authorization = header_token)
#  
#  authors_genres <-
#    req %>%
#    req_url_path_append("authors") %>%
#    req_perform() %>%
#    resp_body_json(simplifyVector = TRUE)
#  
#  
#  all_users <-
#    lapply(seq_len(nrow(authors_genres)), function(i) {
#    req %>%
#      req_url_path_append("books") %>%
#      req_url_query(author = authors_genres$author[[i]], genre = authors_genres$genre[[i]]) %>%
#      req_perform() %>%
#      resp_body_json(simplifyVector = TRUE) %>%
#      .$user_id
#  })
#  
#  table(unlist(all_users))

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  main_api_path <- paste0(az_api$api_web, "/api/v1/amazon/")
#  header_token <- paste0("Bearer ", amazon_bearer_tokens())
#  
#  # Loop through all authors, extract books and count user_ids.
#  req <-
#    main_api_path %>%
#    request() %>%
#    req_headers(Authorization = header_token)
#  
#  authors_genres <-
#    req %>%
#    req_url_path_append("authors") %>%
#    req_perform() %>%
#    resp_body_json(simplifyVector = TRUE)
#  
#  
#  all_users <-
#    lapply(seq_len(nrow(authors_genres)), function(i) {
#    req %>%
#      req_url_path_append("books") %>%
#      req_url_query(author = authors_genres$author[[i]], genre = authors_genres$genre[[i]]) %>%
#      req_perform() %>%
#      resp_body_json(simplifyVector = TRUE) %>%
#      .$user_id
#  })
#  
#  all_users <- unlist(all_users)
#  
#  all_tags <-
#    lapply(all_users, function(user) {
#    req %>%
#      req_url_path_append("products_users") %>%
#      req_url_query(user_id = user) %>%
#      req_perform() %>%
#      resp_body_json(simplifyVector = TRUE) %>%
#      .$tags
#  })
#  
#  sort(table(unlist(all_tags)))

## ---- echo = FALSE------------------------------------------------------------

all_user_products <- function(user_id) {
  products_user <-
    req %>%
    req_url_path_append("products_users") %>%
    req_url_query(user_id = user_id) %>%
    req_perform() %>%
    resp_body_json(simplifyVector = TRUE)
  
  all_names <- 
    lapply(products_user$product_id, function(x) {
    req %>%
      req_url_path_append("products") %>%
      req_url_query(product_id = x) %>%
      req_perform() %>%
      resp_body_json(simplifyVector = TRUE) %>%
      .$name
  })

  unlist(all_names)
}

## -----------------------------------------------------------------------------
all_user_products(user_id = 187)

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  main_api_path <- paste0(az_api$api_web, "/api/v1/amazon/")
#  header_token <- paste0("Bearer ", amazon_bearer_tokens())
#  
#  req <-
#    main_api_path %>%
#    request() %>%
#    req_headers(Authorization = header_token)
#  
#  req %>%
#    req_url_path_append("users") %>%
#    req_url_query(user_id = 319, country = "Germany") %>%
#    req_perform()
#  
#  # You can fix it by supplying one or another argument
#  req %>%
#    req_url_path_append("users") %>%
#    req_url_query(country = "Germany") %>%
#    req_perform()
#  

## ----automating-bicing, echo = FALSE, eval = TRUE-----------------------------
main_dir_api <- "./images/automating_bicing"

knitr::opts_chunk$set(
  echo = TRUE,
  eval = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.align = "center",
  fig.path = paste0(main_dir_api, "/automatic_rmarkdown/"),
  fig.asp = 0.618
)


## -----------------------------------------------------------------------------
library(scrapex)
library(httr2)
library(dplyr)
library(readr)

bicing <- api_bicing()

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "main_bicing_docs.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "endpoint_bicing.png"))

## -----------------------------------------------------------------------------
rt_bicing <- paste0(bicing$api_web, "/api/v1/real_time_bicycles")
rt_bicing

## ---- message = TRUE, collapse = TRUE-----------------------------------------
resp_output <- 
  rt_bicing %>%
  request() %>% 
  req_perform()

resp_output

## -----------------------------------------------------------------------------
sample_output <-
  resp_output %>%
  resp_body_json() %>%
  head(n = 2)

sample_output

## -----------------------------------------------------------------------------
sample_output %>%
  lapply(data.frame) %>%
  bind_rows()

## -----------------------------------------------------------------------------
all_stations <-
  resp_output %>%
  resp_body_json()

all_stations_df <- 
  all_stations %>%
  lapply(data.frame) %>%
  bind_rows()

all_stations_df

## -----------------------------------------------------------------------------
real_time_bicing <- function(bicing_api) {
  rt_bicing <- paste0(bicing_api$api_web, "/api/v1/real_time_bicycles")
  
  resp_output <- 
    rt_bicing %>%
    request() %>% 
    req_perform()
  
  all_stations <-
  resp_output %>%
  resp_body_json()

  all_stations_df <- 
    all_stations %>%
    lapply(data.frame) %>%
    bind_rows()
  
  all_stations_df
}

## -----------------------------------------------------------------------------
first <- real_time_bicing(bicing) %>% select(in_use) %>% rename(first_in_use = in_use)
second <- real_time_bicing(bicing) %>% select(in_use) %>% rename(second_in_use = in_use)
bind_cols(first, second)

## -----------------------------------------------------------------------------
save_bicing_data <- function(bicing_api) {
  # Perform a request to the bicing API and get the data frame back
  bicing_results <- real_time_bicing(bicing_api)
  
  # Specify the local path where the file will be saved
  local_csv <- "/home/jorge.cimentada/bicing/bicing_history.csv"
  
  # Extract the directory where the local file is saved
  main_dir <- dirname(local_csv)

  # If the directory does *not* exist, create it, recursively creating each folder  
  if (!dir.exists(main_dir)) {
    dir.create(main_dir, recursive = TRUE)
  }

  # If the file does not exist, save the current bicing response  
  if (!file.exists(local_csv)) {
    write_csv(bicing_results, local_csv)
  } else {
    # If the file does exist, the *append* the result to the already existing CSV file
    write_csv(bicing_results, local_csv, append = TRUE)
  }
}

## ---- eval = FALSE------------------------------------------------------------
#  save_bicing_data(bicing)
#  Sys.sleep(5)
#  save_bicing_data(bicing)
#  
#  bicing_history <- read_csv("/home/jorge.cimentada/bicing/bicing_history.csv")
#  bicing_history %>%
#    distinct(current_time)

## ---- echo = FALSE------------------------------------------------------------
dates <- c(lubridate::ymd_hms("2022-12-20 23:51:56"), lubridate::ymd_hms("2022-12-20 23:52:04	"))

tibble(
  current_time = dates
)

## ---- echo = FALSE, include = FALSE-------------------------------------------
file.remove("/home/jorge.cimentada/bicing/bicing_history.csv")

## ---- eval = FALSE------------------------------------------------------------
#  bicing_history %>%
#    filter(streetName == "Ribes") %>%
#    select(current_time, streetName, in_use)

## ---- echo = FALSE------------------------------------------------------------
tibble(
  current_time = dates,
  streetName = c("Ribes", "Ribes"), 
  in_use = c(13, 19) 
)

## ---- eval = FALSE------------------------------------------------------------
#  library(scrapex)
#  library(httr2)
#  library(dplyr)
#  library(readr)
#  
#  bicing <- api_bicing()
#  
#  real_time_bicing <- function(bicing_api) {
#    rt_bicing <- paste0(bicing_api$api_web, "/api/v1/real_time_bicycles")
#  
#    resp_output <-
#      rt_bicing %>%
#      request() %>%
#      req_perform()
#  
#    all_stations <-
#    resp_output %>%
#    resp_body_json()
#  
#    all_stations_df <-
#      all_stations %>%
#      lapply(data.frame) %>%
#      bind_rows()
#  
#    all_stations_df
#  }
#  
#  save_bicing_data <- function(bicing_api) {
#    # Perform a request to the bicing API and get the data frame back
#    bicing_results <- real_time_bicing(bicing_api)
#  
#    # Specify the local path where the file will be saved
#    local_csv <- "/home/jorge.cimentada/bicing/bicing_history.csv"
#  
#    # Extract the directory where the local file is saved
#    main_dir <- dirname(local_csv)
#  
#    # If the directory does *not* exist, create it, recursively creating each folder
#    if (!dir.exists(main_dir)) {
#      dir.create(main_dir, recursive = TRUE)
#    }
#  
#    # If the file does not exist, save the current bicing response
#    if (!file.exists(local_csv)) {
#      write_csv(bicing_results, local_csv)
#    } else {
#      # If the file does exist, the *append* the result to the already existing CSV file
#      write_csv(bicing_results, local_csv, append = TRUE)
#    }
#  }
#  
#  save_bicing_data(bicing)

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "console_ls_bicing.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "results_api_bicing_console.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "ls_bicing_history.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "bicing_history_csv.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "main_menu_crontab.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "rscript_cron.png"))

## ---- echo = FALSE, eval = TRUE, out.width = "100%"---------------------------
knitr::include_graphics(file.path(main_dir_api, "bicing_history_cron.png"))

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  library(scrapex)
#  library(httr2)
#  library(dplyr)
#  library(readr)
#  
#  bicing <- api_bicing()
#  
#  real_time_bicing <- function(bicing_api) {
#    rt_bicing <- paste0(bicing_api$api_web, "/api/v1/real_time_bicycles")
#  
#    resp_output <-
#      rt_bicing %>%
#      request() %>%
#      req_perform()
#  
#    all_stations <-
#    resp_output %>%
#    resp_body_json()
#  
#    all_stations_df <-
#      all_stations %>%
#      lapply(data.frame) %>%
#      bind_rows()
#  
#    all_stations_df
#  }
#  
#  save_bicing_data <- function(bicing_api) {
#    local_logs <- "/home/jorge.cimentada/bicing/logs.txt"
#  
#    if (!file.exists(local_logs)) {
#      file.create(local_logs)
#    }
#  
#    # Perform a request to the bicing API and get the data frame back
#    bicing_results <- real_time_bicing(bicing_api)
#  
#    # Logs
#    separator <- "#############################################################################\n"
#    timestamp <- paste0("Current timestamp of request ", unique(bicing_results$current_time), "\n")
#    df_dims <- paste0("Number of columns: ", ncol(bicing_results), " \nNumber rows: ", nrow(bicing_results), "\n")
#    write_lines(c(separator, timestamp, df_dims), local_logs, append = TRUE)
#  
#    # Specify the local path where the file will be saved
#    local_csv <- "/home/jorge.cimentada/bicing/bicing_history.csv"
#    # Extract the directory where the local file is saved
#    main_dir <- dirname(local_csv)
#  
#    # If the directory does *not* exist, create it, recursively creating each folder
#    if (!dir.exists(main_dir)) {
#      dir.create(main_dir, recursive = TRUE)
#    }
#  
#    # If the file does not exist, save the current bicing response
#    if (!file.exists(local_csv)) {
#      write_csv(bicing_results, local_csv)
#    } else {
#      # If the file does exist, the *append* the result to the already existing CSV file
#      write_csv(bicing_results, local_csv, append = TRUE)
#    }
#  }
#  
#  save_bicing_data(bicing)

