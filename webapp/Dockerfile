# Use the official NGINX base image
FROM nginx:alpine

# Copy custom HTML for "Hello World"
COPY index.html /usr/share/nginx/html/index.html

# Create a custom NGINX configuration to expose /health endpoint
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
EXPOSE 80