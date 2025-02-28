library(purrr)


options(repos = c(CRAN = "https://cloud.r-project.org"))

main_dir <- here::here()
to_save <- file.path(main_dir, "r_scripts")
all_chapters <- list.files(path = main_dir, pattern = "[0-9].+\\.Rmd")
from_files <- file.path(main_dir, all_chapters)
from_files <- c(
    "/home/jorge/repositories/dataharvesting/book/02-primer_webscraping.Rmd", 
    "/home/jorge/repositories/dataharvesting/book/03-data_formats.Rmd"
    )

to_files <- gsub("Rmd", "R", file.path(to_save, all_chapters))
to_files <- c(
    "/home/jorge/repositories/dataharvesting/book/r_scripts/02-primer_webscraping.R", 
    "/home/jorge/repositories/dataharvesting/book/r_scripts/03-data_formats.R"
    )

map2(from_files, to_files, knitr::purl)
