# Dockerfile (Backend)
FROM dart:stable AS build

WORKDIR /app

# Copy pubspec files first
COPY backend/pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy the entire backend code
COPY backend/ .

# Compile the application
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary
COPY --from=build /app/bin/server /app/bin/server

# Expose port
EXPOSE 8080

# Run the server
CMD ["/app/bin/server"]