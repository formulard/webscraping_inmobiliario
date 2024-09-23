log_info("Pacakges and source files") #  ---------------------------------------------------------

box::use(
  stringr[str_detect],
  dplyr[filter],
  purrr[map, possibly, set_names],
  dplyr[bind_rows, as_tibble],
  glue[glue],
)

box::use(
  supercasas = scripts/functions/functions_supercasas
)

log_info("Import files") # ----------------------------------------------------------------------
url_supercasas <- readRDS("data/supercasas/url_supercasas.rds")
data_supercasas <- readRDS("data/supercasas/data_supercasas.rds")

log_info("Get data") # --------------------------------------------------------------------------

provincias <- supercasas$provincias |>
  filter(str_detect(provincia_name, "Santo Domingo|Punta Cana"))

log_info("Get today's urls")

today_urls <- provincias$provincia_id |>
  set_names(provincias$provincia_name) |>
  map(
    \(provincia_code) {
      supercasas$get_url_propiedades(provincia_code)
    },
    .progress = TRUE
  ) |> 
  unlist()

new_urls <- setdiff(today_urls, url_supercasas)

log_info("Get data")
new_data_supercasas <- new_urls |>
  map(
    possibly(supercasas$get_property_data, data.frame()),
    .progress = TRUE
  ) |>
  bind_rows() |>
  supercasas$tidy_property_data()

log_success(glue("{nrow(new_data_supercasas)} downloaded from supercasas.com"))

log_info("Update hitorical files") # ------------------------------------------------------------

data_supercasas <- data_supercasas |>
  bind_rows(new_data_supercasas) |>
  as_tibble()

all_urls <- c(url_supercasas, new_urls)

if (nrow(new_data_supercasas) > 0) {
  saveRDS(data_supercasas, "data/supercasas/data_supercasas.rds")
  saveRDS(all_urls, "data/supercasas/url_supercasas.rds")
}
