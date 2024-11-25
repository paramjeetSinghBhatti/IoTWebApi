#!/bin/bash
# Replace placeholders in appsettings.production.json with environment variables
sed -i "s|\${DB_SERVER}|${DB_SERVER}|g" /app/appsettings.production.json
sed -i "s|\${DB_NAME}|${DB_NAME}|g" /app/appsettings.production.json
sed -i "s|\${DB_USER}|${DB_USER}|g" /app/appsettings.production.json
sed -i "s|\${DB_PASSWORD}|${DB_PASSWORD}|g" /app/appsettings.production.json

# Start the application
exec dotnet IoTWebApi.dll