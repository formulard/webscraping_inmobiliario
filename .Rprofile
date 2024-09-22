source("renv/activate.R")

tryCatch(
  {
    library(here)
    library(logger)
  },
  error = function(error) {
    install.packages("here")
    install.packages("logger")
  }
)

options(box.path = here::here())
log_layout(layout_glue_colors)
