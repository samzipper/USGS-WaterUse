## USGS_01_DownloadWaterUseData.R
#' Download county-level water use data from USGS.

source(file.path("src", "paths+packages.R"))

## load counties of interest
# 'masterid' field is FIPS (county code)
sf_counties <- sf::st_read(file.path("data", "AIMHPA_counties_fullyContained.geojson"), 
                           stringsAsFactors=F)

## get USGS water use data
states_HPA <- c("KS", "NM", "TX", "OK", "CO", "NE", "WY", "SD")

# WU categories - get these from the URL when requesting data online
WU_categories <- 
  c(
    "TP",  # total population
    "PS",  # public supply
    "DO",  # domestic
    "CO",  # commercial
    "IN",  # industrial
    "LI",  # livestock
    "LS",  # livestock (stock)
    "LA",  # livestock (animal specialties)
    "IT",  # irrigation (total)
    "IG",  # irrigation (golf course)
    "IC"   # irrigation (crop)
    )

for (state in states_HPA){
  # get data
  df_state <- 
    readNWISuse(stateCd = state,
                countyCd = "ALL",
                categories = WU_categories) %>% 
    transform(masterid = paste0(state_cd, county_cd)) %>% 
    subset(masterid %in% sf_counties$masterid)
  
  # put into overall data frame
  if (state == states_HPA[1]){
    df_HPA <- df_state
  } else {
    df_HPA <- rbind(df_HPA, df_state)
  }
  
  print(paste0(state, " complete"))
}

# save output
write.csv(df_HPA, file.path("data", "derived", "USGS_01_DownloadWaterUseData.csv"),
          row.names=F)
