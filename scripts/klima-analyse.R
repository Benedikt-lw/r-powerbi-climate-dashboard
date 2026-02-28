library(jsonlite)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

laender_codes <- c("DEU", "ESP", "SWE", "FRA", "SRB")
klima_master <- data.frame()

for (land_code in laender_codes) {
  
  dynamische_url <- paste0("https://cckpapi.worldbank.org/api/v1/cru-x0.5_timeseries_tas,pr_timeseries_annual_1901-2024_mean_historical_cru_ts4.09_mean/", land_code, "?_format=json")
  
  roh <- fromJSON(dynamische_url)
  df <- if ("data" %in% names(roh)) as.data.frame(roh$data) else as.data.frame(roh)
  
  df_long <- df %>%
    pivot_longer(
      cols = everything(), 
      names_to = "roh_name", 
      values_to = "wert"
    ) %>%
    
    separate(roh_name, into = c("variable", "country", "year", "monat_drop"), sep = "\\.") %>%
    select(-monat_drop) %>%          
    mutate(year = as.numeric(year)) %>%
    filter(year >= 1990 & year <= 2022) 
  

  klima_master <- bind_rows(klima_master, df_long)
}


klima_final <- klima_master %>%
  pivot_wider(names_from = variable, values_from = wert)



glimpse(klima_final)
klima_final <- klima_final %>% mutate(year = as.integer(year))
glimpse(klima_final)

summary(klima_final)

unique(klima_final$country)

write_csv(klima_final, "klima_daten_clean.csv")