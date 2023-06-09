# Official Dart image: https://hub.docker.com/_/dart
FROM dart:3.0.0 AS builder

# Resolve app dependencies & copy over.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=builder /runtime/ /
COPY --from=builder /app/bin/server /app/bin/

# Start server.
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
