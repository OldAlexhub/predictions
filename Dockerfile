# Use a minimal base image for Plumber
FROM rstudio/plumber:latest

# Install additional R packages with better layer caching
RUN R -e "install.packages(c('dplyr', 'mongolite', 'prophet', 'lubridate', 'dotenv'))"

# Set working directory
WORKDIR /app

# Copy only necessary files for the application
COPY api.R /app/

# Set environment variables securely (instead of hardcoding secrets in Dockerfile)
ENV PORT=8000

# Expose the port used by the Plumber API
EXPOSE $PORT

# Switch to a non-root user for security purposes
USER plumber

# Use ENTRYPOINT to ensure the correct process is run when the container starts
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('/app/api.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))"]
