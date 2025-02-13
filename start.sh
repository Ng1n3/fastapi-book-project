#!/bin/bash

# Debugging: Print the value of PORT
echo "PORT is set to: $PORT"

# Replace PORT in nginx.conf
envsubst "\$PORT" < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Debugging: Print the generated nginx.conf
echo "Generated nginx.conf:"
cat /etc/nginx/conf.d/default.conf

# Verify nginx configuration (validate the correct file)
nginx -t -c /etc/nginx/conf.d/default.conf || exit 1  # Exit if the configuration is invalid

# Start Uvicorn
uvicorn main:app --host 127.0.0.1 --port 6060 &

# Start Nginx in the foreground
nginx -g 'daemon off;' -c /etc/nginx/conf.d/default.conf