library(tidyverse)
library(Hmisc)
library(corrplot)
library(rgdal)
library(sf)
library(viridis)


#getwd()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# read cleaned data set
employed_data <- read_csv("../Data Files/ABS/Employed_SA2.csv")
sa2_data <- read_csv("../../Raw Data/Data Files/ABS/Mesh_Blocks/MB_2016_NSW.csv")

nsw_sa2 <- sa2_data %>% 
  filter(STATE_NAME_2016 == "New South Wales") %>% 
  distinct(SA2_MAINCODE_2016, SA2_NAME_2016)

nsw_data <- employed_data %>% 
  inner_join(nsw_sa2, by = c("SA2_CODE" = "SA2_MAINCODE_2016"))

# There are a couple of outliers
ggplot(nsw_data) +
  geom_histogram(aes(x = PERC_UNEMPLOYED), bins = 50)

# What are the outliers
nsw_data %>% 
  filter(PERC_UNEMPLOYED > 0.2)

## DATA DECISION - REMOVE these outliers
nsw_data <- nsw_data %>% 
  filter(PERC_UNEMPLOYED < 0.2)

# What about the zero unemployment places
nsw_data %>% 
  filter(PERC_UNEMPLOYED == 0.0)

## DATA DECISION - KEEP, for now

ggplot(nsw_data) +
  geom_histogram(aes(x = PERC_UNEMPLOYED), bins = 50)

# What do the whole numbers look like
ggplot(nsw_data) +
  geom_histogram(aes(x = UNEMPLOYED), bins = 50)

#
mean(nsw_data$PERC_UNEMPLOYED)
median(nsw_data$PERC_UNEMPLOYED)

#sa2_shape <- readOGR("../../Raw Data/Data Files/ABS/SA2_Shapefile/SA2_2016_AUST.shp")
sa2_shape <- st_read("../../Raw Data/Data Files/ABS/SA2_Shapefile/SA2_2016_AUST.shp", quiet = TRUE)

combined_df <- merge(nsw_data, sa2_shape, by.x = "SA2_CODE", by.y = "SA2_MAIN16")

combined_df %>% 
  filter(GCC_NAME16 == "Greater Sydney") %>% 
  ggplot() +
  geom_sf(aes(fill = PERC_UNEMPLOYED)) +
  scale_fill_viridis("Percent Unemployed") +
  theme_bw()

combined_df %>% 
  filter()
  ggplot() +
  geom_sf(aes(fill = PERC_UNEMPLOYED)) +
  scale_fill_viridis("Percent Unemployed") +
  theme_bw()
  
combined_df %>% 
  filter(SA2_NAME_2016 != "Lord Howe Island") %>% 
  ggplot() +
  geom_sf(aes(fill = PERC_UNEMPLOYED)) +
  scale_fill_viridis("Percent Unemployed") +
  theme_bw()

# highest unemployment outside of Sydney
combined_df %>% 
  filter(GCC_NAME16 != "Greater Sydney") %>% 
  arrange(desc(PERC_UNEMPLOYED))