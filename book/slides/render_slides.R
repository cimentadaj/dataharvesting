library(quarto)

# Function to render a single QMD file
render_qmd_to_html <- function(qmd_file) {
  quarto::quarto_render(input = qmd_file, output_format = "revealjs")
}

# Recursively find all QMD files in the current directory and subdirectories
qmd_files <- list.files(pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)

# Apply the rendering function to each QMD file
lapply(qmd_files, render_qmd_to_html)
