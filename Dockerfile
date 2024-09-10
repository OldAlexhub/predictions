# Use the R plumber base image
FROM rstudio/plumber:latest

# Install additional R packages
RUN R -e "install.packages(c('dplyr', 'mongolite', 'prophet', 'lubridate', 'dotenv'))"

# Set the working directory inside the container
WORKDIR /app

# Copy only necessary files for the application
COPY api.R /app/

# Ensure .dockerignore is used to prevent unnecessary files from being copied into the image

# Set environment variables securely
ENV PORT 8000

# Expose the port that the Plumber API will use
EXPOSE $PORT

# Switch to a non-root user for security reasons
USER plumber

# Use CMD to run the Plumber API server on the specified port
CMD ["R", "-e", "pr <- plumber::plumb('/app/api.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))"]

