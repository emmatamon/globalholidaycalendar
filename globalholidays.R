# Global Holiday Calendar Generator v.0.1.0

# Gets non-optional holidays from a list of countries and joins them into a single,
# shareable .ics file you can add to your calendar app and share with others.
# Version 0.1

# This script is licensed under Creative Commons Attribution 4.0 (CC BY 4.0)
# You may use, modify, and redistribute this code for any purpose,
# provided you give appropriate credit and include a link to:
# https://github.com/emmatamon/globalholidaycalendar

# Last updated: April 13 2026

# Data source: Calendarific API
# https://calendarific.com/
#

# MODIFY THESE THREE LINES ONLY
api_key = "" # add your API key from your Calendarific account: https://calendarific.com/account/dashboard
countries = c()  # Add a list of country ids in double quotes, separated by commas, eg c("BR", "DE", "MX")
years = c() #add a list of countries you need separated by commas, eg c(2026, 2027, 2028)
filename = ".ics" # add filename before the point, eg "holidays_2026_2028.ics"

# load packages, install using install.packages() via console if needed
library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(dplyr)



# get data

url <- "https://calendarific.com/api/v2/holidays"

all_data <- list()
i <- 1

for (ct in countries) {
  for (yr in years) {
    
    res <- GET(
      url,
      query = list(
        api_key = api_key,
        country = ct,
        year = yr
      )
    )
    
    txt <- content(res, as = "text", encoding = "UTF-8")
    json <- fromJSON(txt, flatten = TRUE)
    
    holidays <- json$response$holidays
    holidays$states <- NULL
    
    if (!is.null(holidays) && nrow(holidays) > 0) {
      holidays$country <- ct
      holidays$year <- yr
      
      all_data[[i]] <- holidays
      i <- i + 1
    }
  }
}

# clean and prep dataframe

all_holidays <- bind_rows(all_data) %>%
  filter( primary_type != "Optional holiday" &
            primary_type != "Optional Holiday" &
            primary_type != "Season") %>% 
  select(name, date.iso, country) %>% 
  distinct(date.iso, name, country) %>%   # remove duplicates
  group_by(date.iso, name) %>%
  summarise(
    countries = paste(sort(unique(country)), collapse = " "),
    .groups = "drop"
  ) %>% 
  transmute(date = as.Date(date.iso),
            name = paste(name, " - ", countries))

#convert to .ics

ics_lines <- c(
  "BEGIN:VCALENDAR",
  "VERSION:2.0",
  "PRODID:-//Holiday Calendar//EN"
)

for (i in seq_len(nrow(all_holidays))) {
  
  dt <- format(all_holidays$date[i], "%Y%m%d")
  dt_end <- format(all_holidays$date[i] + 1, "%Y%m%d")  # all-day event (end is next day)
  
  event <- c(
    "BEGIN:VEVENT",
    paste0("UID:", i, "@holidaycalendar"),
    paste0("DTSTAMP:", format(Sys.time(), "%Y%m%dT%H%M%SZ")),
    paste0("DTSTART;VALUE=DATE:", dt),
    paste0("DTEND;VALUE=DATE:", dt_end),
    paste0("SUMMARY:", all_holidays$name[i]),
    "END:VEVENT"
  )
  
  ics_lines <- c(ics_lines, event)
}

ics_lines <- c(ics_lines, "END:VCALENDAR")

#save ics

writeLines(ics_lines, filename, useBytes = TRUE)
