# Base image for R and Plumber
FROM rstudio/plumber

# Install additional R packages needed
RUN R -e "install.packages(c('dplyr', 'mongolite', 'prophet', 'lubridate'))"

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents (which includes api.R) to /app
COPY . /app

# Expose the port Plumber runs on
EXPOSE 8000

# Run the Plumber API with a fixed path to 'api.R'
CMD ["R", "-e", "pr <- plumber::plumb('/app/api.R'); pr$run(host='0.0.0.0', port=8000)"]

