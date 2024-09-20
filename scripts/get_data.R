# Pacakges and source files -------------------------------------------------------------------
box::use(
  stringr[str_detect],
  dplyr[filter],
  purrr[map, possibly],
  dplyr[bind_rows, as_tibble]
)

box::use(
  supercasas = scripts/functions/functions_supercasas
)

# Import files --------------------------------------------------------------------------------
url_supercasas <- readRDS("data/supercasas/url_supercasas.rds")
data_supercasas <- readRDS("data/supercasas/data_supercasas.rds")

# Get data ------------------------------------------------------------------------------------

provincias <- supercasas$provincias |>
  filter(str_detect(provincia_name, "Santo Domingo|Punta Cana"))

today_urls <- provincias$provincia_id |>
  map(
    \(provincia_code) {
      supercasas$get_url_propiedades(provincia_code)
    },
    .progress = TRUE
  ) |> 
  unlist()

new_urls <- setdiff(today_urls, url_supercasas)

new_data_supercasas <- new_urls |>
  map(
    possibly(supercasas$get_property_data, data.frame()),
    .progress = TRUE
  ) |>
  bind_rows() |>
  supercasas$tidy_property_data()

# Update hitorical files ----------------------------------------------------------------------

data_supercasas <- data_supercasas |>
  bind_rows(new_data_supercasas) |>
  as_tibble()

all_urls <- c(url_supercasas, new_urls)

saveRDS(data_supercasas, "data/supercasas/data_supercasas.rds")
saveRDS(all_urls, "data/supercasas/url_supercasas.rds")
