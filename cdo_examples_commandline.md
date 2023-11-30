## Hands-on tutorial climate model and climate data workshop using CDO commands

The climate data operators, short cdo, are a command line tool to work with netcdfs and grib files.
See https://code.mpimet.mpg.de/projects/cdo/embedded/index.html for a full documentation.

In your jupyter lab session, open a terminal (new tab +, choose Terminal at the very bottom).
The example data to play around with is located here: /net/co2/c2sm-data/rlorenz/climate_model_data_workshop/

You can do "ls" to see whats in there.
> ls /net/co2/c2sm-data/rlorenz/climate_model_data_workshop/

Some of the most commonly used cdo commands include:
- monmean: to calculate monthly means
- ymonmean: to calulate monthly means over multiple years (climatology)
- yearmean: to calculate yearly means
- fldmean: to calculate a mean over space
- seltime, seldate, selyear, selmonth: to select certain time periods, dates, years or months
- sellonlatbox: to select a box using longitude and latitude corners as lon1,lon2,lat1,lat2
- selgridcell: to select a certain grid cell by its indices (comma-separated list or first/last[/inc] range of indices)

The usage is:
cdo COMMAND,PARAMETERS infile.nc outfile.nc

Play around with some of theses commands and check their outcome.
You can use
> ncdump -h outfile.nc

To dump the header of a file onto the terminal.
Or you use the examples in model_example_python.ipynb to check out your new files and plot some data.
