# globalholidaycalendar
Get a ics file for holidays across countries

# Global Holiday Calendar Generator
# 
# Data source: Calendarific API
# https://calendarific.com/
#
# This script is licensed under Creative Commons Attribution 4.0 (CC BY 4.0)
# You may use, modify, and redistribute this code for any purpose,
# provided you give appropriate credit and include a link to:
# https://github.com/emmatamon/globalholidaycalendar
#
## Output  A single ics file
# Each event is formatted as:
# - `Holiday Name – [Country Codes]`


## Data source

Holiday data is retrieved via the Calendarific API:  
https://calendarific.com/

## Requirements

R packages:
- httr
- jsonlite
- dplyr
- purrr

## Usage

1. Insert your Calendarific API key in the script
2. Add the countries,  years and filename
2. Run the script in R
3. Import the generated `.ics` file into your calendar application

## Notes

- Holiday naming may vary across countries and years.
- Some holidays are filtered (e.g. optional or seasonal observances).
- Deduplication is based on date and normalized holiday name.
