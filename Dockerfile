# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project file and restore dependencies
COPY ["dummyapp/dummyapp.csproj", "dummyapp/"]
RUN dotnet restore "dummyapp/dummyapp.csproj"

# Copy all source code
COPY . .
WORKDIR "/src/dummyapp"

# Build the project
RUN dotnet build "./dummyapp.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Stage 2: Publish
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./dummyapp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Expose Render default port
EXPOSE 8080

# Copy published app
COPY --from=publish /app/publish .

# Start the API
ENTRYPOINT ["dotnet", "dummyapp.dll"]
