# Stage 1: Build the FastAPI application
FROM python:3.13-slim AS builder

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Stage 2: Create the final image with Nginx and Python
FROM python:3.13-slim

# Install nginx and gettext-base (for envsubst)
RUN apt-get update && apt-get install -y \
    nginx \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install dependencies
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY --from=builder /app/main.py /app/main.py
COPY --from=builder /app/api /app/api
COPY --from=builder /app/core /app/core
COPY --from=builder /app/config /app/config

# Set up Nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx.conf /etc/nginx/conf.d/default.conf.template

# Remove default Nginx configurations
RUN rm -rf /etc/nginx/sites-enabled/*  # Remove all default site configurations
RUN rm -rf /etc/nginx/sites-available/*  # Remove all default site configurations

# Create necessary directories
RUN mkdir -p /app/static /var/cache/nginx /var/log/nginx

# Copy and set up start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Create nginx temp directories
RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp

# Expose the port (Heroku will override this with $PORT)
EXPOSE 8080

# Use the start script as the entrypoint
CMD ["/start.sh"]