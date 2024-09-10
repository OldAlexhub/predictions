# Use a minimal base image for Plumber
FROM rstudio/plumber:latest

# Install additional R packages
RUN R -e "install.packages(c('dplyr', 'mongolite', 'prophet', 'lubridate', 'dotenv'))"

# Set working directory inside the container
WORKDIR /app

# Copy the necessary files
COPY api.R /app/

# Expose the port that the Plumber API will use
EXPOSE 8000

# Set the environment variable for the port Render will bind to
ENV PORT=8000

# Switch to a non-root user for better security
USER plumber

# CMD to run the Plumber API, using the PORT environment variable
CMD ["R", "-e", "pr <- plumber::plumb('/app/api.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))"]


