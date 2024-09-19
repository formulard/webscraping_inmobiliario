# Pacakges and source files -------------------------------------------------------------------

box::use(
  stringr[str_detect],
  dplyr[filter],
  purrr[map],
)

box::use(
  supercasas = ./functions/functions_supercasas
)

# Import files --------------------------------------------------------------------------------



# Get data ------------------------------------------------------------------------------------

provincias <- supercasas$provincias |>
  filter(str_detect(provincia_name, "Santo Domingo|Punta Cana"))

url_propiedades <- provincias$provincia_id |>
  map(
    \(provincia_code) {
      supercasas$get_url_propiedades(provincia_code)
    },
    .progress = TRUE
  ) |> 
  unlist()

data_supercasas <- url_propiedades |>
  map(
    purrr::possibly(supercasas$get_property_data, data.frame()),
    .progress = TRUE
  )

