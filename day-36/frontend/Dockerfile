# ==========================================
# Stage 1: Build React application
# ==========================================

FROM node:22-alpine AS build

WORKDIR /app

# Copy dependency files first
# This allows Docker to cache npm install
COPY package*.json ./

RUN npm ci

# Copy application source
COPY . .

# Build production React application
RUN npm run build


# ==========================================
# Stage 2: Serve with Nginx
# ==========================================

FROM nginx:alpine

# Remove default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy React production build
COPY --from=build /app/dist /usr/share/nginx/html

# Copy our Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
