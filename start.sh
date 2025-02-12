#!/bin/bash

# Replace PORT in nginx.conf
sed -i "s/\$PORT/$PORT/g" /etc/nginx/conf.d/default.conf

# Start supervisord
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf