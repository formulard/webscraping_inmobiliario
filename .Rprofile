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
logger::log_layout(logger::layout_glue_colors)
