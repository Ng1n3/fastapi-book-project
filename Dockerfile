# Stage 1: Build the FastAPI application
FROM python:3.13-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Stage 2: Create the final image with Nginx and Python
FROM python:3.13-slim

# Install nginx and supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
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
COPY config/nginx.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default || true
RUN mkdir -p /app/static

# Copy supervisor configuration
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy and set up start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose the port (Render will override this with $PORT)
EXPOSE 80

# Use the start script as the entrypoint
CMD ["/start.sh"]