FROM nginx:stable-alpine

LABEL org.opencontainers.image.source="https://github.com/justin-mike-collab/grow"

# Copy the welcome page
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]