# 1. Introduction ==============================================================
# Script to download daily weather data from FAWN and convert to two dataframes
# that are suitable for uploading to a Florida Crop BMP dataset.
#
# The user currently has to specify a station name as listed here:
# https://fawn.ifas.ufl.edu/data/fawnpub/DSSAT/
# A map of the locations can be found at https://fawn.ifas.ufl.edu/. Select
# 'Station Data' and any weather variable to display the map. Clicking on a 
# value will display the station name.

# The FAWN data are described here: https://fawn.ifas.ufl.edu/data/
# The prefered citation is: Peeling, J.A., Judge, J., Misra, V. et al. 
# Gap-free 16-year (2005–2020) sub-diurnal surface meteorological observations across Florida. Sci Data 10, 907 (2023).
# URL: https://doi.org/10.1038/s41597-023-02826-4

# To use this script, specify the station name and date range in the section
# toward the end of this script.

# 1.1 Load required package ====================================================
if (!require("httr")) install.packages("httr", dependencies = TRUE)
library(httr)

# 1.2. Set working directory to script location. ===============================
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 2. Provide station name ======================================================
# The station names can be found at: https://fawn.ifas.ufl.edu/data/fawnpub/DSSAT/
# Alternately, the home page for FAWN opens with a map: https://fawn.ifas.ufl.edu
# From there, one can navigate to a desired location.
# Enter station information here:
station_name <- "Fort Pierce"  # Replace name with the FAWN station name
station_id   <- "FLAFTP"   # Replace the ID with the one for the Crop BMP dataset., preferably as "FLA---"

# Enter desired start and end dates:
start_date <- "2022-01-01"
end_date <- "2024-12-31"

# 3. ==========================================================
# Function to download and create daily weather dataframe from FAWN data
get_daily_weather_data <- function(station_name, station_id, start_date, end_date) {
  # Construct the URL
  base_url <- "https://fawn.ifas.ufl.edu/data/fawnpub/DSSAT/"
  # Special handling for names with two parts.
  # URLencode converts "Live Oak.csv" to "Live%20Oak.csv"
  file_name <- URLencode(paste0(station_name, ".csv"))
  
  url <- paste0(base_url, file_name)
  
  # Download the data
  temp_file <- tempfile(fileext = ".csv")
  download.file(url, temp_file, method = "auto")
  
  # Read the daily data into a dataframe, skipping 2 header rows
  weather_data <- read.csv(temp_file, skip = 2)
  
  # Print the first few rows and structure of the data for debugging
  print(head(weather_data))
  print(str(weather_data))
  
  # Check the column names
  print(colnames(weather_data))
  
  # Convert the 'Date.Time' column to Date type
  if ("Date.Time" %in% colnames(weather_data)) {
    weather_data$Date <- as.Date(weather_data$Date.Time, format = "%Y-%m-%d")
    
  # Remove Date.time variable the reorder
    weather_data <- weather_data[ , -c(1)]
    number_weather_vars <- ncol(weather_data)
    weather_data <- weather_data[ , c(number_weather_vars, 1:(number_weather_vars - 1))]
  # Filter data based on the user-specified date range
  # Obtain the first and last date in the original data set  
    first_date_value <- weather_data$Date[1]
    last_date_value  <-  weather_data$Date[length(weather_data$Date)]
    
  # Convert the user-specified start and end dates.    
    start_date <- as.Date(start_date)
    end_date <- as.Date(end_date)
    
  # If the start_date is before the first_date, output a warning.
    if (start_date < first_date_value) {
      warning("The start_date is earlier than the first date in the FAWN data file.")
    }
  
    # If the end_date is after the last_date, output a warning.
    if (end_date > last_date_value) {
      warning("The end_date is later than the first date in the FAWN data file.")
    }
  
  # Subset the daily weather data according to the specified start and end dates
    weather_data <- subset(weather_data, Date >= start_date & Date <= end_date)

  # Read the station metadata into a dataframe
    station_data <- read.csv(temp_file, nrows = 1)
    print(station_data)
    station_data$'Weather station ID' <- station_id
    station_data$'Weather station name' <- station_name
    station_data$'Weather station link' <- "https://fawn.ifas.ufl.edu/data/fawnpub/DSSAT/"
    station_data$'Anonymize' <- "N"  # Assuming no need to anonyize because pubic info
    print(names(station_data))
    station_data <- station_data[ , c(6, 7, 1:3, 9, 4, 5, 8)]
    print(names(station_data))
    station_info_FDACS <- c("Weather station ID", "Weather station name", "Latitude of station", "Longitude of station", 
                            "Elevation of weather station", "Anonymize", 
                            "Weather station temperature sensor height", 
                            "Weather station wind sensor height",
                            "Weather station link")
    names(station_data) <- station_info_FDACS
    
    # Remove the temporary file
    unlink(temp_file)
    
    # Since functions can only return one object, create a single object by 
    # creating a list. 
    return(list(weather_data = weather_data, station_data = station_data))    
  } else {
    # Halt execution if 'Date.Time' is not in the original FAWN data.
    stop("The expected column 'Date.Time' is not present in the data.")
  }
}

# 4. Call the function with arguments as set at top of script. ====
output <- get_daily_weather_data(station_name, station_id, start_date, end_date)

#' The object 'output' contains two block of data, which are separated into two 
#' dataframes here:
# 4.1 Station metadata ====
station_metadata_df <- output$station_data

# 4.2 Daily data for the requested interval ====
daily_weather_df    <- output$weather_data
daily_weather_df$'Weather station ID' <- station_id
daily_weather_df    <- daily_weather_df[ , c(9, 1, 4, 3, 5,2, 6:8)]

# 5. Access the daily data and metadata using additional R code ====
# 5.1 Display portions of the data frames
print(head(daily_weather_df))
print(station_metadata_df)

# 5.2 Save the data as two *.CSV files ====
output_metadata_name <- paste0(station_id, "_meta.csv")
write.csv(station_metadata_df, file = output_metadata_name, row.names = FALSE, na = "")

output_daily_name <- paste0(station_id, "_daily.csv")
write.csv(daily_weather_df, file = output_daily_name, row.names = FALSE, na = "")

# End of script