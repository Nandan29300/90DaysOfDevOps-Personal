# Day 36 – Docker Project: Dockerize a Full Application

## DockerBuddy – Docker Command Reference

### 1. Project Overview

For Day 36 of my #90DaysOfDevOps journey, I built **DockerBuddy**, a beginner-friendly Docker command reference application.

The goal was to take a complete application and Dockerize it end-to-end using:

- React
- Nginx
- Node.js / Express
- PostgreSQL
- Docker
- Docker Compose

DockerBuddy provides commonly used Docker commands grouped by category, along with descriptions and examples. It also includes search and copy functionality to make the reference useful for developers who are learning Docker.

---

## 2. Why I Built DockerBuddy

Instead of building a complex business application, I wanted to create something small, practical, and directly useful for people starting with Docker.

DockerBuddy focuses on commonly used Docker concepts such as:

- Images
- Containers
- Networks
- Volumes
- Docker Compose
- Debugging
- Registry operations
- Cleanup
- Build commands
- Configuration

The application currently contains 80+ useful Docker commands.

---

## 3. Architecture

```text
                         Internet
                            |
                            v
                    EC2 Public IP :80
                            |
                            v
                 +----------------------+
                 |   Frontend Container |
                 |   React + Nginx      |
                 |        Port 80       |
                 +----------+-----------+
                            |
                         /api/*
                            |
                            v
                 +----------------------+
                 |   Backend Container  |
                 |   Node.js / Express  |
                 |       Port 5000      |
                 +----------+-----------+
                            |
                            v
                 +----------------------+
                 |   PostgreSQL         |
                 |       Port 5432      |
                 +----------------------+
                            |
                            v
                 Persistent Docker Volume
```

### Services

| Service | Technology | Container Port | Host Port |
|---|---|---:|---:|
| Frontend | React + Nginx | 80 | 80 |
| Backend | Node.js + Express | 5000 | 5000 |
| Database | PostgreSQL | 5432 | 5432 |

PostgreSQL is not exposed directly to the public internet in the final Compose setup. It is accessed by the backend through the Docker network.

---

## 4. Project Structure

```text
day-36/
│
├── .gitignore
├── docker-compose.yml
├── .env.example
├── README.md
├── day-36-docker-project.md
│
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── package.json
│   ├── package-lock.json
│   └── src/
│       ├── server.js
│       └── db.js
│
├── frontend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── nginx.conf
│   ├── index.html
│   ├── package.json
│   ├── package-lock.json
│   ├── public/
│   │   └── docker.svg
│   └── src/
│       └── ...
│
└── database/
    └── init.sql
```

---

## 5. Dockerfiles

The project uses **two Dockerfiles**.

### Backend Dockerfile

Location:

```text
backend/Dockerfile
```

The backend image uses Node.js Alpine as a lightweight base image.

Main concepts used:

- Alpine base image
- Working directory
- Dependency installation
- Copying application source
- Non-root user
- Production dependency installation
- Container startup command

The backend is packaged as:

```text
nandan56/dockerbuddy-backend:v1.0.0
```

### Frontend Dockerfile

Location:

```text
frontend/Dockerfile
```

The frontend uses a **multi-stage Docker build**.

The first stage:

```text
Node.js
   |
   +-- npm ci
   |
   +-- npm run build
   |
   v
React production build
```

The second stage:

```text
Nginx Alpine
   |
   +-- Copy React dist/
   |
   v
Production frontend
```

This keeps the final frontend image smaller and removes the Node.js build environment from the runtime image.

The frontend is packaged as:

```text
nandan56/dockerbuddy-frontend:v1.0.0
```

---

## 6. Non-Root Backend Container

The backend Dockerfile creates a dedicated application user instead of running the Node.js application as root.

Conceptually:

```dockerfile
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
```

This improves container security by following the principle of running applications with only the permissions they require.

---

## 7. .dockerignore

Both frontend and backend have their own `.dockerignore`.

Typical excluded files/directories include:

```text
node_modules
npm-debug.log
.git
.gitignore
.env
dist
```

This prevents unnecessary files from being sent into the Docker build context.

---

## 8. Docker Compose

The application is orchestrated using:

```text
docker-compose.yml
```

The Compose application contains three services:

```text
db
backend
frontend
```

### PostgreSQL

The database uses the official image:

```text
postgres:16-alpine
```

It uses environment variables for:

```text
POSTGRES_USER
POSTGRES_PASSWORD
POSTGRES_DB
```

### Backend

The backend uses the Docker Hub image:

```text
nandan56/dockerbuddy-backend:v1.0.0
```

It connects to PostgreSQL using the Docker Compose service name:

```text
db
```

instead of using `localhost`.

### Frontend

The frontend uses:

```text
nandan56/dockerbuddy-frontend:v1.0.0
```

Nginx serves the React application on port 80 and proxies `/api` requests to the backend.

---

## 9. Docker Network

Docker Compose creates a custom bridge network:

```text
dockerbuddy-network
```

The containers communicate using service names.

For example:

```text
frontend -> backend:5000
backend  -> db:5432
```

This is important because `localhost` inside a container refers to that same container, not another service.

---

## 10. PostgreSQL Persistence

The PostgreSQL service uses a named Docker volume:

```text
dockerbuddy-postgres-data
```

The volume stores PostgreSQL data outside the container filesystem.

This means the database data can survive container recreation.

Conceptually:

```text
PostgreSQL Container
        |
        v
dockerbuddy-postgres-data
        |
        v
Persistent database data
```

---

## 11. Database Healthcheck

The PostgreSQL service has a Docker healthcheck using `pg_isready`.

The backend waits for the database service to become healthy before starting.

This avoids starting the application before PostgreSQL is ready to accept connections.

---

## 12. Environment Variables

Sensitive configuration is kept outside the source code.

The project uses an environment file for values such as:

```text
POSTGRES_USER
POSTGRES_PASSWORD
POSTGRES_DB
```

The real `.env` file should not be committed to Git.

The root `.gitignore` contains:

```text
.env
node_modules/
dist/
*.log
```

An `.env.example` file can be committed with placeholder values.

---

## 13. Docker Hub

The application was published as two Docker images.

### Frontend

```text
nandan56/dockerbuddy-frontend:v1.0.0
```

Docker Hub:

https://hub.docker.com/repository/docker/nandan56/dockerbuddy-frontend

### Backend

```text
nandan56/dockerbuddy-backend:v1.0.0
```

Docker Hub:

https://hub.docker.com/repository/docker/nandan56/dockerbuddy-backend

The PostgreSQL image was not pushed because the application uses the official public image:

```text
postgres:16-alpine
```

Users do not need to manually pull the frontend and backend separately when using the provided Compose file. Docker Compose pulls the required images automatically.

---

## 14. Image Versioning

Instead of relying only on `latest`, the application images were tagged with an explicit version:

```text
v1.0.0
```

Images:

```text
nandan56/dockerbuddy-frontend:v1.0.0
nandan56/dockerbuddy-backend:v1.0.0
```

Versioned tags make deployments more reproducible because a Compose file can explicitly specify which application version should run.

---

## 15. Final Image Sizes

The Docker images on the EC2 instance were:

```text
Backend  : 245 MB
Frontend : 93.7 MB
```

These are the Docker image sizes displayed by `docker images`.

The content-size values shown by Docker are separate from the local disk-usage figures.

---

## 16. Testing the Application

### Check running services

```bash
sudo docker compose ps
```

Expected services:

```text
dockerbuddy-frontend
dockerbuddy-backend
dockerbuddy-db
```

with PostgreSQL showing:

```text
healthy
```

### Test the frontend

```bash
curl http://localhost
```

The response should contain the React application's HTML.

### Test the backend health endpoint

```bash
curl http://localhost/api/health
```

Expected response:

```json
{
  "status": "healthy",
  "database": "connected",
  "service": "dockerbuddy-api"
}
```

### Test the commands API

```bash
curl http://localhost/api/commands
```

The endpoint returns the Docker command reference data.

A combined verification:

```bash
echo "=== HEALTH ==="
curl -s http://localhost/api/health

echo -e "\n\n=== COMMANDS ==="
curl -s http://localhost/api/commands
```

---

## 17. Fresh Docker Hub Deployment Test

One of the most important parts of this project was verifying that the application could run using the images published to Docker Hub.

The flow was:

```text
Local Docker images
        |
        v
Remove application images
        |
        v
docker compose pull
        |
        v
Docker Hub
        |
        +---- Frontend v1.0.0
        |
        +---- Backend v1.0.0
        |
        +---- PostgreSQL official image
        |
        v
docker compose up -d
        |
        v
Full application running
```

The Compose file references the Docker Hub images instead of building the application locally.

Example:

```yaml
frontend:
  image: nandan56/dockerbuddy-frontend:v1.0.0

backend:
  image: nandan56/dockerbuddy-backend:v1.0.0
```

The database continues to use:

```yaml
db:
  image: postgres:16-alpine
```

This demonstrates that the application can be deployed from published container images rather than depending on locally built images.

---

## 18. Challenges Faced

### Challenge 1 – Frontend container could not resolve `backend`

During manual testing, the frontend container produced:

```text
host not found in upstream "backend"
```

The reason was that the frontend was started with `docker run` on a separate Docker network.

The Nginx configuration expected:

```text
backend:5000
```

This hostname is resolvable when the frontend and backend are connected to the same Docker Compose network.

The solution was to run the frontend through Docker Compose.

---

### Challenge 2 – Host port 5000 was already in use

A backend was initially running directly on the EC2 host while Docker Compose also attempted to expose port 5000.

This caused:

```text
address already in use
```

The solution was to stop the old process and allow the Compose-managed backend to own the port.

---

### Challenge 3 – Backend could not connect to PostgreSQL

The backend initially reported:

```text
database disconnected
```

The database was reachable on port 5432, but the backend configuration needed the correct database hostname.

Inside Docker Compose, the correct database hostname is:

```text
db
```

not:

```text
localhost
```

After correcting the database configuration, PostgreSQL connected successfully.

---

### Challenge 4 – Docker Compose versus manual Docker commands

Manual `docker run` commands were useful for testing individual containers, but they did not automatically provide the shared network configuration required by the application.

Docker Compose solved this by managing:

- Services
- Networking
- Environment variables
- Dependencies
- Volumes
- Healthchecks
- Port mappings

---

## 19. What I Learned

Through this project I learned how to:

- Write Dockerfiles for real applications
- Use multi-stage Docker builds
- Reduce runtime image contents
- Run applications as non-root users
- Use `.dockerignore`
- Containerize a React frontend
- Serve a React production build with Nginx
- Containerize a Node.js backend
- Connect containers through a custom Docker network
- Run PostgreSQL with Docker
- Persist database data with volumes
- Configure Docker Compose healthchecks
- Use environment variables
- Publish images to Docker Hub
- Version Docker images
- Use Docker Compose with remote images
- Test a fresh deployment from Docker Hub
- Debug container networking and port conflicts

---

## 20. Final Result

DockerBuddy is now a complete containerized application consisting of:

```text
React + Nginx
      |
      v
Node.js + Express
      |
      v
PostgreSQL
```

The application can be started using Docker Compose and the application images are available through Docker Hub.

The project demonstrates the complete flow:

```text
Application
    ↓
Dockerfiles
    ↓
Docker Compose
    ↓
Containers
    ↓
Docker Hub
    ↓
Fresh Deployment
```

### DockerBuddy

A simple Docker command reference built as a practical Day 36 Docker project.

---

## 21. Docker Hub Links

Frontend:

https://hub.docker.com/repository/docker/nandan56/dockerbuddy-frontend

Backend:

https://hub.docker.com/repository/docker/nandan56/dockerbuddy-backend

---

## 22. Conclusion

Day 36 was focused on moving beyond individual Docker commands and actually using Docker to package and deploy a complete application.

The main takeaway was that Docker is not just about creating images. A real deployment also involves:

```text
Images
+
Containers
+
Networks
+
Volumes
+
Environment Variables
+
Healthchecks
+
Compose
+
Container Registry
```

DockerBuddy brought these concepts together into one small, practical project.
