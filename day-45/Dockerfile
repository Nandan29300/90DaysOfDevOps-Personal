# syntax=docker/dockerfile:1

FROM nginx:alpine

LABEL org.opencontainers.image.title="DockerFlow CI/CD Demo"
LABEL org.opencontainers.image.description="Modern Docker CI/CD demo for the 90 Days of DevOps challenge"

# Remove the default Nginx page.
RUN rm -rf /usr/share/nginx/html/*

# Copy the static application.
COPY index.html /usr/share/nginx/html/index.html

# Nginx listens on port 80.
EXPOSE 80

# Run Nginx in the foreground so Docker keeps the container alive.
CMD ["nginx", "-g", "daemon off;"]
