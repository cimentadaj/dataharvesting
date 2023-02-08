# CHAPTER 2

# 1. Europe has an ageing problem and the mandatory retirement age is being constantly revised. In the `scrapex` package there's a copy of the "Retirement in Europe" wikipedia website [https://en.wikipedia.org/wiki/Retirement_in_Europe](https://en.wikipedia.org/wiki/Retirement_in_Europe). You can find the local link in the function `retirement_age_europe_ex()`. Can you inspect the website, parse the table and replicate the plot below? (Hint: you might need the function `str_sub` from the `stringr` package).

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

# When parsing the elections table, we parsed all tables of the Wikipedia table into `all_tables`. Among all those tables, there's one table that documents the years at which there were general elections, presidential elections, european elections, local elections, regional elections and referendums in Spain. Can you extract into a *numeric* vector all the years at which there were general elections in Spain? (Hint: you might need `str_split` and other `stringr` functions and the resulting vector should start by 1810 and end with 2019).

important_dates <- all_tables[[6]]
names(important_dates) <- c("type_election", "years")

all_years <-
  important_dates %>%
  filter(type_election == "General elections") %>%
  pull(years) %>%
  str_split(pattern = "\n") %>%
  .[[1]] %>%
  str_sub(1, 4) %>%
  as.numeric()

general_elections <- all_years[!is.na(all_years)]
general_elections

# 3. Building on your previous code, can you tell me the years where local elections, european elections and general elections overlapped?

important_dates <- all_tables[[6]]
names(important_dates) <- c("type_election", "years")

all_years <-
  important_dates %>%
  filter(
    type_election %in% c("General elections", "Local elections", "European elections")
  ) %>%
  pull(years) %>%
  str_split(pattern = "\n") %>%
  lapply(str_sub, 1, 4) %>%
  lapply(as.numeric)

overlapping_years <- intersect(all_years[[1]], intersect(all_years[[2]], all_years[[3]]))
overlapping_years



# CHAPTER 3

# 1. Extract the values for the `align` attributes in `html_raw` (Hint, look at the function `xml_children`).

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

xml_raw <- read_xml(xml_test)

div_nodes <- xml_child(html_raw, search = 2)
xml_attrs(xml_children(div_nodes), "align")

# 2. Extract the occupation of Carol Kalp from `xml_raw`

carol_node <- xml_child(xml_raw, search = 2)
person_node <- xml_child(carol_node, search = 1)
occupation <- xml_child(person_node, search = 3)
xml_text(occupation)

# 3. Extract the text of all `<div>` tags from `html_raw`. Your result should look specifically like this:
## [1] "\n      First text\n    "  "\n      Second text\n    "
## [3] "\n      Third text\n    "  "\n      Fourth text\n    "


div_nodes <- xml_child(html_raw, search = 2)
xml_text(xml_children(div_nodes), "align")

# 4. Manually create an XML string which contains a root node, then two children nested within and then two grandchildren nested within each child. The first child and the second grandchild of the *second* child should have an attribute called family set to '1'. Read that string and find those two attributes but only with the function `xml_find_all` and `xml_attrs`.


custom_xml <- "<root>
<child1 family='1'>
<granchild1>
</granchild1>
<granchild2>
</granchild2>
</child1>


<child2>
<granchild1>
</granchild1>
<granchild2 family='1'>
</granchild2>
</child2>
</root>"

custom_raw <- read_xml(custom_xml)

# First attribute
xml_attrs(xml_find_all(custom_raw, "/root/child1"))

# Second attribute
xml_attrs(xml_find_all(custom_raw, "/root/child2/granchild2"))

# 5. The output of all the previous exercises has been either a `xml_nodeset` or an `html_document` (you can read it at the top of the print out of your results):

## {html_document}
## <html>
## [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=UTF-8 ...
## [2] <body>\n    <div align="left">\n      First text\n    </div>\n    <div al ...

# Can you extract the text of the last name of Carol the scientist only using R subsetting rules on your object? For example `some_object$people$person$...` (Hint: `xml2` has a function called `as_list`).

xml_list <- as_list(xml_raw)
xml_list$people$carol$person$last_name[[1]]



# CHAPTER 4

# 1. Extend our case study to the period "State building into the Kingdom of France (987–1453)":

# Note that this will require you to change some of our previous code and think of slightly different regexp strategies. When done, merge it with our results of the case study to produce the complete lineage of France's history of monarchy.

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

# 2. Take a look at this regexp: `I like .+\\.`. It says: match the phrase `I like` followed by any character (`.`) repeated one or more times (`+`) until you find a dot (`\\.`). When applied to the string below it extracts the entire string:

str_extract_all(text, "I like .+?\\.")[[1]]


# 3. Can you extract all unique royal houses from the Wikipedia document? That is, produce a vector like this one:

history_france_html <- history_france_ex()
history_france <- read_html(history_france_html)

history_france %>%
  xml_text() %>%
  str_extract_all("House of .+?\\s") %>%
  .[[1]] %>%
  str_trim() %>%
  str_replace_all("[:punct:]", "") %>%
  unique()

# Hint: No need to use any XPath, `xml_text()` the entire document to extract all of the text of the website and apply regexp to grab the houses. You'll need to use `?` and also figure out what `[:punct:]` does in regexp.



# CHAPTER 5


newspaper_link <- elpais_newspaper_ex()
newspaper <- read_html(newspaper_link)

# 1. How many `jpg` and `png` images are there in the website? (Hint: look at the source code and figure out which tag and *attribute* contains the links to the images).

newspaper %>%
  xml_find_all("//img[contains(@src, 'jpg')]") %>%
  length()

newspaper %>%
  xml_find_all("//img[contains(@src, 'png')]") %>%
  length()


# 2. How many articles are there in the entire website?

newspaper %>%
  xml_find_all("//article") %>%
  length()

# 3. Out of all the headlines (by headlines I mean the bold text that each article begins with), how many contain the word 'climate'?

newspaper %>%
  xml_find_all("//h2[@class='c_t ']/a[contains(text(), 'climate')]")

# 4. What is the city with more reporters?

library(stringr)
newspaper %>%
  xml_find_all("//span[@class='c_a_l']") %>%
  xml_text() %>%
  # Some cities are combined together with , or /
  str_split(pattern = ",|/") %>%
  unlist() %>%
  # Remove all spaces before/after the city for counting properly
  trimws() %>%
  table()

# 5. What is the headline of the article with the most words in the description? (Hint: remember that `.//` searcher for all tags but *only below* the current tag. `//` will search for all tags in the document, regardless of whether it's above the current selected node) The text you'll want to measure the amount of letters is below the bold headline of each news article:


art_p <-
  newspaper %>%
  # Grab only the articles that have a p tag *below* each article.
  # p tags are for paragraphs and contains the description of a file
  xml_find_all("//article[.//p]")

lengthy_art <-
  art_p %>%
  xml_text() %>%
  nchar() %>%
  which.max()

art_p[lengthy_art] %>%
  xml_find_all(".//h2/a") %>%
  xml_text()

