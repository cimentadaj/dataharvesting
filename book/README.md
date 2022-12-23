# Data Harvesting

<!-- badges: start -->
[![R-CMD-check](https://github.com/cimentadaj/dataharvesting/workflows/bookdown/badge.svg)](https://github.com/cimentadaj/dataharvesting/actions)
<!-- badges: end -->

This is a work in progress book for the course data harvesting at UC3M. The book can be found at [https://cimentadaj.github.io/dataharvesting/index.html](https://cimentadaj.github.io/dataharvesting/index.html). This book contains an `renv` environment to reproduce this book. To activate this environment, launch an R session in the root of this README and run `renv::restore()`.  See [here](https://rstudio.github.io/renv/articles/collaborating.html) for more details.


# Details to reproduce the book

Each **bookdown** chapter is an .Rmd file, and each .Rmd file can contain one (and only one) chapter. A chapter *must* start with a first-level heading: `# A good chapter`, and can contain one (and only one) first-level heading.

Use second-level and higher headings within chapters like: `## A short section` or `### An even shorter section`.

The `index.Rmd` file is required, and is also your first book chapter. It will be the homepage when you render the book.

## Render book

You can render the HTML version of this example book without changing anything:

1.  Find the **Build** pane in the RStudio IDE, and

2.  Click on **Build Book**, then select your output format, or select "All formats" if you'd like to use multiple formats from the same book source files.

Or build the book from the R console:

```{r, eval=FALSE}
bookdown::render_book()
```

## Preview book

As you work, you may start a local server to live preview this HTML book. This preview will update as you edit the book when you save individual .Rmd files. You can start the server in a work session by using the RStudio add-in "Preview book", or from the R console:

```{r eval=FALSE}
bookdown::serve_book()
```