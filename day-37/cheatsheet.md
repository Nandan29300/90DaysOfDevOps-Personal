# Docker Cheat Sheet

> Short, practical Docker reference for daily use.

---

## Container Commands

```bash
docker run nginx
docker run -it ubuntu bash
docker run -d nginx
docker run -d --name web nginx
docker run -d -p 8080:80 nginx

docker ps
docker ps -a
docker start <container>
docker stop <container>
docker rm <container>
docker rm -f <container>
docker exec -it <container> bash
docker logs <container>
docker logs -f <container>
```

---

## Image Commands

```bash
docker images
docker pull nginx
docker build -t my-app .
docker build -t my-app:1.0 .
docker tag my-app username/my-app:1.0
docker push username/my-app:1.0
docker rmi <image>
docker inspect <image>
docker login
```

---

## Volume Commands

```bash
docker volume create mydata
docker volume ls
docker volume inspect mydata
docker volume rm mydata
docker run -v mydata:/data my-app
```

---

## Bind Mounts

```bash
docker run -v "$(pwd)":/app my-app
```

```text
HOST_PATH:CONTAINER_PATH
```

---

## Network Commands

```bash
docker network create app-network
docker network ls
docker network inspect app-network
docker network connect app-network <container>
docker network disconnect app-network <container>
docker run -d --network app-network --name app my-app
```

Containers on the same user-defined network can communicate using their container/service names.

---

## Compose Commands

```bash
docker compose up
docker compose up -d
docker compose up --build
docker compose down
docker compose down -v
docker compose ps
docker compose logs
docker compose logs -f
docker compose build
```

---

## Cleanup Commands

```bash
docker system df
docker system prune
docker system prune -a
docker volume prune
docker network prune
```

> Be careful with cleanup commands because they can delete resources you still need.

---

# Dockerfile Instructions

## FROM

Defines the base image.

```dockerfile
FROM node:22
```

## RUN

Runs a command while building the image.

```dockerfile
RUN npm install
```

## COPY

Copies files/directories from the Docker build context into the image.

```dockerfile
COPY . .
```

## ADD

Copies files and provides additional features such as local tar archive extraction.

```dockerfile
ADD app.tar.gz /app
```

## WORKDIR

Sets the working directory.

```dockerfile
WORKDIR /app
```

## EXPOSE

Documents the port the application uses; it does not publish the port to the host.

```dockerfile
EXPOSE 3000
```

## CMD

Provides the default command/arguments for the container.

```dockerfile
CMD ["npm", "start"]
```

## ENTRYPOINT

Defines the main executable for the container.

```dockerfile
ENTRYPOINT ["python"]
```

## HEALTHCHECK

Defines a health check for the running container.

```dockerfile
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
```

---

# Useful Dockerfile Pattern

```dockerfile
FROM node:22

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

---

# Multi-Stage Build Pattern

```dockerfile
FROM node:22 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
```

---

# CMD vs ENTRYPOINT

```text
ENTRYPOINT → main executable
CMD        → default command/arguments
```

Example:

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

Result:

```text
python app.py
```

---

# Port Mapping

```text
-p HOST_PORT:CONTAINER_PORT
```

Example:

```bash
docker run -p 8080:80 nginx
```

```text
Host 8080 → Container 80
```

---

# Storage

```text
Named volume → Docker-managed persistent storage
Bind mount   → Host path mapped into container
```

---

# Networking

```text
User-defined network → Containers communicate using service/container names
```

Example:

```text
app → db:5432
```

---

# Docker Workflow

```text
Dockerfile
    ↓
docker build
    ↓
Docker Image
    ↓
docker tag
    ↓
Docker Hub
    ↓
docker push
    ↓
docker run
    ↓
Container
```
