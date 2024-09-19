box::use(
  glue[glue],
  rvest[read_html, html_elements, html_attr],
  stringr[str_subset],
)

#' Get properties url from a single page
#' 
#' @param code_provincia code from the `provincias` object
#' @param skip integer, number of pages to skip
#' 
#' @export
get_url <- function(code_provincia = "10005", skip = 0) {
  glue::glue('https://www.supercasas.com/buscar/?Locations=10005&PagingPageSkip=0') |>
    rvest::read_html() |> 
    rvest::html_elements('#bigsearch-results-inner-container ul li a') |>
    rvest::html_attr('href') |>
    stringr::str_subset(
      pattern = "/casa|apartamento|solar|finca|naves|oficina|edificio|penthouse|negocio|locales-comerciales")
}

#' Get properties URLs from multiples pages
#' 
#' @param code_provincia code from the `provincias` object
#' @param start_page integer, first page
#' @param end_page integer, ending page
#' 
#' @export
get_url_propiedades <- function(code_provincia = "10005", start_page = 0, end_page = 41) {
  safe_get_url <- purrr::possibly(get_url, otherwise = NA_character_, quiet = TRUE)
  page_sequence <- seq(start_page, end_page)
  
  purrr::map(
    page_sequence,
    \(skip) safe_get_url(code_provincia, skip)
  ) |>
    unlist()
}

#' Get property data
#' 
#' @return data frame with property data: scrape_date, property_type, price, bathrooms and others
#' @export
get_property_data <- function(url_casa) {
  scrape_date <- Sys.Date()

  pattern_type <- paste0(
    "casa|apartamento|solar|finca|nave|oficina|edificio|",
    "penthouse|negocio|local comercial|locales comerciales")

  url_casa <- paste0("https://www.supercasas.com", url_casa)

  html <- rvest::read_html(url_casa)

  tipo_vivienda <- html |>
    rvest::html_nodes("#detail-ad-header h2") |>
    rvest::html_text() |>
    stringr::str_to_lower() |>
    stringr::str_extract(pattern = pattern_type)
  
  precio <- html |>
    rvest::html_nodes("#detail-ad-header h3") |>
    rvest::html_text()
  
  # extraer atributos con cantidad de habitaciones,
  # baños y paqueos
  atributos <- html |>
    rvest::html_nodes(".secondary-info span") |>
    rvest::html_text()

  # Cantidad de habitaciones  
  habitaciones <- atributos[1]

  # Cantidad de baños
  banios <- atributos[2]

  parqueos <- ifelse(
    length(atributos) < 3, 
    NA_character_,
    atributos[3]
  )

  # Dirección
  direccion <- html |>
    rvest::html_nodes("tr:nth-child(1) td") |>
    rvest::html_text() |>
    utils::tail(1)

  # Dimensiones
  metraje <- html |>
    rvest::html_nodes("tr:nth-child(3) td:nth-child(2)") |>
    rvest::html_text()

  # Detalles
  detalles <- html |>
    rvest::html_nodes("#detail-ad-info-specs ul li") |>
    rvest::html_text() |>
    base::paste(collapse = ", ")

  data.frame(
    scrape_date = scrape_date,
    tipo_vivienda = tipo_vivienda,
    precio = precio,
    habitaciones = habitaciones,
    banios = banios,
    parqueos = parqueos,
    direccion = direccion,
    metraje = metraje,
    detalles = detalles
  )
}

#'@export
tidy_property_data <- function(df) {
  df %>%
    tidyr::separate(precio, into = c("divisa", "precio"), sep = " ") |>
    dplyr::mutate(
      precio = readr::parse_number(precio),
      habitaciones = readr::parse_number(habitaciones),
      banios = readr::parse_number(banios),
      parqueos = readr::parse_number(parqueos),
      metraje = readr::parse_number(metraje)
    )
}

#' Provincias supercasas
#' @export
provincias <- tibble::tribble(
  ~provincia_id,                      ~provincia_name,
  "10167",                               "Azua",
  "10174",                           "Bahoruco",
  "10180",                           "Barahona",
  "10008", "Bávaro, Punta Cana y la Altagracía",
  "10191",                            "Dajabón",
  "10192",                             "Duarte",
  "10200",                           "El Seibo",
  "10201",                         "Elías Piña",
  "10208",                          "Espaillat",
  "10677",                             "España",
  "10214",                         "Hato Mayor",
  "10218",                      "Independencia",
  "10225",                          "La Romana",
  "10238",                            "La Vega",
  "10245",             "María Trinidad Sánchez",
  "10250",                     "Monseñor Nouel",
  "10262",                       "Monte Cristi",
  "10254",                        "Monte Plata",
  "10275",                         "Pedernales",
  "10277",                            "Peravia",
  "10281",                       "Puerto Plata",
  "10289",                            "Salcedo",
  "10291",                             "Samaná",
  "10302",                      "San Cristóbal",
  "10309",           "San Francisco de Macorís",
  "10268",                   "San José de Ocoa",
  "10314",                           "San Juan",
  "10320",               "San Pedro de Macoris",
  "10334",                    "Sánchez Ramírez",
  "10095",                           "Santiago",
  "10339",                 "Santiago Rodríguez",
  "10005",               "Santo Domingo Centro",
  "10347",                 "Santo Domingo Este",
  "10375",                "Santo Domingo Norte",
  "10385",                "Santo Domingo Oeste",
  "10343",                           "Valverde"
)
 