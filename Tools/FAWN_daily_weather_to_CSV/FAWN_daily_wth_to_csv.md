<style>
</style>

**Upload FAWN Daily Weather Data**

**Script:**                  Upload_FAWN_daily_data

**Date:**                     April 9, 2025

**Introduction**

In completing a Florida Crop BMP workbook,
researchers need to obtain daily weather data from a nearby, well-maintained
weather station. The Florida Automated Weather Network (FAWN) currently
maintains 42 stations across the state. Daily summaries that meet the Crop BMP dataset requirements are available at [Index of /data/fawnpub/DSSAT](https://fawn.ifas.ufl.edu/data/fawnpub/DSSAT/). The data are provided in a column-separated variable (CSV) format. However, the
files include a header section and use variable names that differ from those
used in the FDACS BMP datasets. The script reformats the data into two blocks,
station metadata , so minor reformatting is needed for use in BMP datasets.

This script described here downloads the complete data from a given station, reformats the data for easier loading to an FDACS BMP dataset, and allows the user to specify the start and end dates of the daily weather. The basic steps are:

1.       Inspect the contents of [Index of /data/fawnpub/DSSAT](https://fawn.ifas.ufl.edu/data/fawnpub/DSSAT/) to identify the file corresponding to the desired station. A map of station locations is available at the FAWN web site: [https://fawn.ifas.ufl.edu](https://fawn.ifas.ufl.edu). From the Station Data, select a weather variable such as ‘Current Temp (°F)’. Values will appear in red circles for each station. Zoom or pan to the region of interest. Then click on the red circle corresponding to the station of interest. The station name will appear as the header for the column of
displayed data at the right.

2.       Open the script ‘FAWN_daily_wth_to_csv’ in RStudio.

3.       Enter the station name into the script as the ‘station_name’.

4.       Enter the station identifier into the script as the ‘station_id’. We suggest a six-letter identifier, where the first three characters are “FLA”, and the last three characters are the first characters of the station name or a similar abbreviation.

5.       Enter the desired date ranges as ‘start_date’ and ‘end_date’. Note that stations vary in when the data series began. For Crop BMP datasets, we suggest that the ‘start_date’ be at least 90 days prior to the first field management event (e.g., tillage or planting).

6.       Run the script.

7.     The script should create two column-separated variate (CSV files), one with station metadata and one with the daily values for the specified interval. The variables for daily data should match the BMP template except that the new dataset contains one extra variable, average vapor pressure.

8. Cut and paste the data into the template as required.

**Troubleshooting**

                 The most likely source of errors is incorrect spelling or capitalization of the
station name. The name must match exactly the name at the FAWN mentioned in step 1. 

        We recently encountered a problem with the DSSAT-formatted daily datasets not being updated on a regular basis. It turned out that the process used by FAWN to automate the updates had stopped. If the data lack recent dates, please contact FAWN.
