# Base image for R
FROM rstudio/plumber

# Install additional R packages needed
RUN R -e "install.packages(c('dplyr', 'mongolite', 'prophet', 'lubridate'))"

# Copy the API R script to the container
COPY api.R /app/api.R

# Expose the port Plumber runs on
EXPOSE 8000

# Run the Plumber API
CMD ["R", "-e", "pr <- plumber::plumb('/app/api.R'); pr$run(host='0.0.0.0', port=8000)"]
