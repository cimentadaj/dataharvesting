library(purrr)

main_dir <- here::here()
to_save <- file.path(main_dir, "r_scripts")
all_chapters <- list.files(path = main_dir, pattern = "[0-9].+\\.Rmd")
from_files <- file.path(main_dir, all_chapters)
to_files <- gsub("Rmd", "R", file.path(to_save, all_chapters))
map2(from_files, to_files, knitr::purl)
