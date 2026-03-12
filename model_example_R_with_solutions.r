# Climate Model and Climate data workshop, hands-on session¶

# This script is part of the climate model and climate data workshop.
# It showcases how to use climate model data in R. However, it is not a R course!

# We are using the terra, rnaturalearth and ggplot2 packages.


# Load necessary libraries
library(terra)
library(dplyr)
library(sf)
library(rnaturalearth) # For regional masking similar to regionmask

# Load CMIP6 data for a specific variable and print the dataset
# --- Load Data ---
inpath <- '/net/co2/c2sm-data/rlorenz/climate_model_data_workshop'
ifile <- file.path(inpath, 'tas_Amon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_201001-201412.nc')
variable_name <- 'tas'

# Open the dataset (In R, terra handles NetCDF lazily by default)
da <- rast(ifile, subds = variable_name)
print(da)

# ❓ Questions

#    1. How many years are covered in the dataset?
#    2. What is the data frequency?
#    3. How many variables does the dataset contain?


### Exercise 1.1

# Calculate the grid spacing in latitudinal and longitudinal directions.

# --- Calculate Grid Spacing ---
# In terra, res() gives you (x, y) resolution directly
spacing <- res(da)
cat(sprintf('Grid Spacing - Latitudinal: %.4f degrees\n', spacing[2]))
cat(sprintf('Grid Spacing - Longitudinal: %.4f degrees\n', spacing[1]))

## 2 Subsetting Data

### Subset data for a specific year and print the dataset

# --- Subset by Time (2012) ---
# Filter layers where the date starts with 2012
da_2012 <- da[[grep("^2012", time(da))]]
print(da_2012)

#### Hint
# time(da) to get the vector of dates and then subset the layers using standard indexing or grep

#### Exercise 2.1

# Calculate the average temperature for the year 2012 and print the result.

# --- Calculate Mean Temperature for 2012 ---
mean_temp_2012 <- global(da_2012, fun = "mean", na.rm = TRUE)
units_str <- units(da)[1]
cat(sprintf('Mean Temperature for 2012: %.2f %s\n', mean(mean_temp_2012$mean), units_str))

### Subset data for a specific region using latitude and longitude bounds

# --- Subset by Spatial Polygon (Bounding Box) ---
# terra uses ext(xmin, xmax, ymin, ymax)
e <- ext(5, 16, 45, 55)
da_reg <- crop(da, e)
print(da_reg)

#### Exercise 2.2

# Calculate and print the mean temperature for the selected region.

mean_temp_reg <- global(da_reg, fun = "mean", na.rm = TRUE)
cat(sprintf('Mean Temperature for the Selected Region: %.2f %s\n', mean(mean_temp_reg$mean), units_str))


### Extract data for a specific region using the `regionmask` package

# --- Extract Region using Masking ---
# regionmask's SREX equivalent can be found via naturalearth or custom shapefiles
# Here we'll create a simple mask for "Central Europe"
world <- ne_countries(scale = "medium", returnclass = "sf")
ceu_poly <- world %>% filter(name %in% c("France","Germany", "Switzerland", "Austria", "Poland", 
                                         "Czech Rep.", "Slovakia", "Hungary", "Slovenia", 
                                         "Liechtenstein"))
# Align coordinate systems and mask
da_ceu <- mask(da, vect(ceu_poly))

# or use the actual box values:
ceu_box <- st_polygon(list(matrix(c(5,45, 30,45, 30,50, 5,50, 5,45), ncol=2, byrow=TRUE))) %>%
  st_sfc(crs = 4326)
da_ceu <- mask(da, vect(ceu_box))


print(da_ceu)

#### Exercise 2.3

# Calculate and print the mean temperature for Central Europe for the full timeseries.

#### Exercise 2.4

# Calculate the mean temperature in space and time for another region of choice. 


## 3 Plotting and Visualization

# Load additional plotting libraries
library(ggplot2)
library(tidyterra) # Extension for terra + ggplot2
library(sf)


### 3.1 Regional Maps

#### Plot the outline of the Central European region and overlay data

# 1. Define the Projection (Lambert Conformal Conic)
# We define a PROJ string similar to your Python central_longitude=15
target_crs <- "+proj=lcc +lat_1=45 +lat_2=55 +lat_0=50 +lon_0=15 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

# 2. Get the Regional Outlines (SREX equivalent via Natural Earth for demo)
# You can also use st_read() if you have the specific SREX shapefile
world <- ne_countries(scale = "medium", returnclass = "sf")

# 3. Select one time step (Equivalent to .isel(time=1))
da_slice <- da_ceu[[2]] # R is 1-indexed, so index 2 is the second time step

# 4. Create the Plot
ggplot() +
  # Plot the Raster data (pcolormesh equivalent)
  geom_spatraster(data = da_slice) +
  
  # Add Country/Region outlines
  geom_sf(data = world, fill = NA, color = "black", size = 0.5) +
  
  # Add labels (Optional: similar to add_label=True)
  # geom_sf_label(data = ceu_poly, aes(label = name)) + 
  
  # Set the Projection and Extent (set_extent equivalent)
  # R uses xlim/ylim in the units of the CRS or coord_sf for lon/lat limits
  coord_sf(xlim = c(-15, 45), ylim = c(40, 65), crs = 4326, expand = FALSE, default_crs = 4326) +
  
  # Styling
  scale_fill_viridis_c(name = units(da)[1], na.value = "transparent") +
  theme_minimal() +
  labs(title = "Mean Temperature - Central Europe",
       subtitle = paste("Time:", time(da_slice)))

#### Exercise 3.1.1

# Customize the projection in the regional map plot:

#    Experiment with different map projections: Instead of the Lambert Conformal Conic string used previously, try updating the crs argument in coord_sf() or the project() function with these common alternatives:

#        - Mercator: "+proj=merc +datum=WGS84"
#        - Mollweide: "+proj=moll"
#        - Robinson: "+proj=robin"

# Example: Testing the Orthographic projection
new_proj <- "+proj=moll"

ggplot() +
  geom_spatraster(data = da_slice) +
  geom_sf(data = world, fill = NA) +
  # Use the new projection here
  coord_sf(crs = new_proj) + 
  theme_minimal() +
  labs(title = "Testing Orthographic Projection")

#### Mask data for Switzerland and plot it on a regional map

# 1. Get Switzerland boundary (equivalent to natural_earth_v5_0_0)
world <- ne_countries(scale = 50, returnclass = "sf")
ch_poly <- world[world$name == "Switzerland", ]

# 2. Mask the data (equivalent to da.where(mask == CH_index))
# 'mask' in terra handles the spatial intersection automatically
da_CH <- mask(da, vect(ch_poly))

# 3. Define the projection (Lambert Conformal Conic)
proj_lcc <- "+proj=lcc +lat_1=45 +lat_2=55 +lat_0=50 +lon_0=15 +datum=WGS84"

# 4. Plotting
ggplot() +
  # Plot the masked raster slice (time index 2 for R's 1-based indexing)
  geom_spatraster(data = da_CH[[2]]) +
  
  # Plot Switzerland boundary
  geom_sf(data = ch_poly, fill = NA, color = "black", size = 0.8) +
  
  # Plot surrounding coastlines/countries for context
  geom_sf(data = world, fill = NA, color = "gray30", linewidth = 0.2) +
  
  # Coordinate system and extent (set_extent equivalent)
  coord_sf(xlim = c(-15, 45), ylim = c(40, 65), crs = 4326, default_crs = 4326) +
  # Try this for a perfect Swiss-centric map
  #coord_sf(crs = 2056)

  # Formatting
  scale_fill_viridis_c(na.value = "transparent", name = "Temperature") +
  theme_minimal() +
  labs(title = "CMIP6 Data Masked for Switzerland",
       subtitle = "Projected in Lambert Conformal Conic")

#### Exercise 3.1.2

# Use another country to mask and plot it.

### 3.2 Global Maps

#### Calculate seasonal means and print the resulting dataset

# 1. Calculate Seasonal Means
# Get the season for each time step in the raster
seasons <- quarters(time(da)) # Returns "Q1", "Q2", etc.
# Alternatively, to get JJA, DJF, etc:
season_names <- c("DJF", "DJF", "MAM", "MAM", "MAM", "JJA", "JJA", "JJA", "SON", "SON", "SON", "DJF")
month_idx <- as.numeric(format(time(da), "%m"))
obs_seasons <- season_names[month_idx]

# Apply the mean across layers grouped by season (equivalent to groupby)
ds_seas <- tapp(da, index = obs_seasons, fun = mean)
print(ds_seas)

#### Plot global map of seasonal mean for a specific season

# Plot JJA in Robinson Projection
ggplot() +
  geom_spatraster(data = ds_seas["JJA"]) +
  geom_sf(data = world, fill = NA, size = 0.2) +
  coord_sf(crs = "+proj=robin") + # Robinson Projection
  scale_fill_viridis_c(name = "Temp (K)", na.value = "transparent") +
  theme_minimal() +
  labs(title = "Mean Temperature: JJA (Global Robinson Projection)")

#### Exercise 3.2.1

# Plot a global map of monthly mean for November.

# 2. Calculate Monthly Means
# Get the month index (1-12) for each layer
months <- as.numeric(format(time(da), "%m"))

# Group by month and calculate mean
ds_month <- tapp(da, index = months, fun = mean)
# Rename layers for clarity (1 -> Jan, etc.)
names(ds_month) <- month.abb 
print(ds_month)

# Plot November (month 11) in Robinson Projection
ggplot() +
  geom_spatraster(data = ds_month["Nov"]) +
  geom_sf(data = world, fill = NA, size = 0.2) +
  coord_sf(crs = "+proj=robin") +
  scale_fill_viridis_c(name = "Temp (K)", na.value = "transparent") +
  theme_minimal() +
  labs(title = "Mean Temperature: November")

#### Exercise 3.2.2

# Create a facet plot showing all four seasons side-by-side.

# 1. Prepare the seasonal data
# We ensure the seasons are in the correct chronological order for the plot
season_levels <- c("DJF", "MAM", "JJA", "SON")
# Subset and reorder ds_seas to match our levels
ds_seas_ordered <- ds_seas[[season_levels]]

# 2. Create the Facet Plot
ggplot() +
  # Plot all layers at once
  geom_spatraster(data = ds_seas_ordered) +
  
  # Add global coastlines
  geom_sf(data = world, fill = NA, color = "white", linewidth = 0.1) +
  
  # Use Robinson projection
  coord_sf(crs = "+proj=robin") +
  
  # Create the 2x2 grid (facets)
  facet_wrap(~lyr, ncol = 2) +
  
  # Styling
  scale_fill_viridis_c(
    name = "Temp (K)", 
    option = "magma", # 'magma' is great for temperature
    na.value = "transparent"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold", size = 12),
    panel.background = element_rect(fill = "aliceblue", color = NA)
  ) +
  labs(
    title = "CMIP6 Seasonal Mean Temperature",
    subtitle = "MPI-ESM1-2-LR Historical (2010-2014)",
    caption = "Projection: Robinson"
  )

