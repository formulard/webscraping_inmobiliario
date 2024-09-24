library(dplyr)
library(rvest)
library(RSelenium)
library(glue)

ciudades_mrhome <- tibble::tribble(
    ~id,              ~name,
    156,  "Santo Domingo D.N.",
    149,  "Santo Domingo Este",
    151, "Santo Domingo Norte",
    150, "Santo Domingo Oeste",
     60,          "Punta Cana",
     59,              "Bávaro",
    121,             "Santiago"
  )

get_url <- function(driver, city_code = "156", page = 1) {
    url <- glue("https://www.mrhome.com.do/propiedades?city={ city_code }&page={ page }")
    driver$navigate(url)
    Sys.sleep(0.5)

    html <- driver$getPageSource()[[1]]
    
    read_html(html) |>
        html_elements(".property-holder div #featured a") |>
        html_attr("href")
}

get_url_propiedades <- function(driver, city_code = 156, start_page = 1, end_page = NULL) {
    url <- glue("https://www.mrhome.com.do/propiedades?city={ city_code }&page={ start_page }")
    
    if (is.null(end_page)) {
        driver$navigate(url)
        n_results <- read_html(html) |>
            html_elements("#info .blue") |>
            html_text() |>
            readr::parse_number()

        end_page <- n_results %% 30
    }

    page_sequence <- seq(start_page, end_page)
    safe_get_url <- purrr::possibly(get_url, otherwise = NA_character_)

    purrr::map(
        (page_sequence),
        \(page) safe_get_url(driver, city_code, page),
        .progress = TRUE
    )
}

rD <- rsDriver(browser = "firefox")
remDr <- rD[["client"]]

url_propiedades <- get_url_propiedades(remDr)
