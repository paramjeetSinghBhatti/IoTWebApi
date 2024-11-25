# Use the official .NET SDK image to build the app
# Replace '8.0' with the version you need
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Set the working directory inside the container
WORKDIR /app

# Copy the .csproj file and restore dependencies
# Only the necessary files are copied at each stage to improve caching
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the application code and build the release
COPY . ./
RUN dotnet publish -c Release -o out

# Use the official .NET Runtime image for the runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory inside the container
WORKDIR /app

# Copy the compiled files from the build stage
COPY --from=build-env /app/out .

## Expose the port that the application listens on
EXPOSE 8080

# Specify the entry point to run the application
ENTRYPOINT ["dotnet", "IoTWebApi.dll"]