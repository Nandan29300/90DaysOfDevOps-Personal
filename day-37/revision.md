# Day 37 – Docker Revision & Cheat Sheet

---

## Self-Assessment Checklist

Mark yourself honestly — **can do**, **shaky**, or **haven't done**:

- [ **can do** ] Run a container from Docker Hub (interactive + detached)
- [ **can do** ] List, stop, remove containers and images
- [ **shaky** ] Explain image layers and how caching works
- [ **shaky** ] Write a Dockerfile from scratch with FROM, RUN, COPY, WORKDIR, CMD
- [ **can do** ] Explain CMD vs ENTRYPOINT
- [ **can do** ] Build and tag a custom image
- [ **shaky** ] Create and use named volumes
- [ **shaky** ] Use bind mounts
- [ **shaky** ] Create custom networks and connect containers
- [ **can do** ] Write a docker-compose.yml for a multi-container app
- [ **can do** ] Use environment variables and .env files in Compose
- [ **shaky** ] Write a multi-stage Dockerfile
- [ **can do** ] Push an image to Docker Hub
- [ **shaky** ] Use healthchecks and depends_on

---

## Quick-Fire Questions

Answer from memory, then verify:

### 1. What is the difference between an image and a container?

- An image is a read-only blueprint/template used to create containers.
- A container is a runtime instance created from a Docker image.

### 2. What happens to data inside a container when you remove it?

- Data stored only in the container's writable layer is deleted when the container is removed.
- Data stored in a named volume or bind mount can persist after the container is removed.

### 3. How do two containers on the same custom network communicate?

- Containers on the same user-defined network can communicate with each other.
- They can use the container/service name instead of relying on container IP addresses.
- Docker provides internal DNS for this.

### 4. What does `docker compose down -v` do differently from `docker compose down`?

- `docker compose down` removes the Compose containers and networks.
- `docker compose down -v` also removes the volumes associated with the Compose project.
- Be careful with `-v` because persistent data stored in those volumes can be deleted.

### 5. Why are multi-stage builds useful?

- Multi-stage builds separate the build environment from the runtime environment.
- Only the required build output is copied into the final image.
- This helps create smaller and cleaner production images and reduces unnecessary dependencies.

### 6. What is the difference between `COPY` and `ADD`?

- `COPY` copies files/directories from the Docker build context into the image.
- `ADD` can also copy files, but provides additional features such as automatic extraction of local tar archives.
- For normal file copying, `COPY` is generally preferred.

### 7. What does `-p 8080:80` mean?

- It maps host port `8080` to container port `80`.
- Format: `-p HOST_PORT:CONTAINER_PORT`.

### 8. How do you check how much disk space Docker is using?

- Using:
  `docker system df`
- `df -h` checks Linux filesystem disk usage, while `docker system df` shows Docker resource usage.

---

## Revisit Weak Spots

### 1. Explain image layers and how caching works

- Gained a clearer understanding that Docker images are made up of layers.
- Docker can reuse previously built layers when the relevant build step and its inputs have not changed.
- Dockerfile instruction order can affect build-cache efficiency.
- Multi-stage builds and Docker caching are separate concepts.

### 2. Explain CMD vs ENTRYPOINT

- Understood the difference between CMD and ENTRYPOINT.
- `ENTRYPOINT` defines the main executable.
- `CMD` provides default command/arguments that can be overridden at runtime.
- They can also be used together.

Example:

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

This results in:

```text
python app.py
```

---

## Other Concepts Revisited

### Docker Storage

- Named volumes are Docker-managed persistent storage.
- Bind mounts map a host path into a container.
- Container filesystem data is not persistent after container removal unless stored using persistent storage.

### Docker Networking

- User-defined networks allow containers to communicate.
- Containers on the same custom network can communicate using their names.
- Docker provides internal DNS for container/service discovery.
- Common network drivers include bridge, host, none, and overlay.

### Multi-Stage Builds

- A builder stage can contain compilers, dependencies, and build tools.
- The final stage can contain only the runtime dependencies and application output.
- This helps reduce final image size and unnecessary packages.

### Healthchecks

- A running container does not always mean the application inside it is healthy.
- `HEALTHCHECK` can be used to test application health.
- Health status can be `starting`, `healthy`, or `unhealthy`.

### Docker Compose

- Compose is used to define and manage multi-container applications.
- Services can communicate using service names.
- `.env` files can be used for configuration.
- `depends_on` controls service dependency/startup ordering, but basic `depends_on` does not necessarily mean the dependency is ready to accept connections.

---

## Day 29–36 Progress Summary

During Days 29–36, I progressed from basic Docker usage into:

- Docker containers
- Docker images
- Dockerfiles
- Docker instructions
- Building custom images
- Image tagging
- Docker Hub
- Volumes
- Bind mounts
- Networks
- Multi-stage Dockerfiles
- Docker Compose
- Environment variables
- `.env` files
- `depends_on`
- Healthchecks
- A final Docker project

I also pushed around 3–4 images to Docker Hub during this learning period.

---

## Suggested Flow (45–60 minutes)

- 10 min: go through the checklist honestly
- 10 min: answer quick-fire questions
- 20 min: build the Docker cheat sheet
- 10 min: revisit weak areas

---

## Final Day 37 Status

- [x] Reviewed Docker fundamentals
- [x] Completed self-assessment
- [x] Answered quick-fire questions
- [x] Corrected weak conceptual areas
- [x] Identified weak topics
- [x] Revisited image layers and caching
- [x] Revisited CMD vs ENTRYPOINT
- [x] Revisited storage concepts
- [x] Revisited networking concepts
- [x] Revisited multi-stage builds
- [x] Revisited healthchecks
- [x] Revisited Compose concepts

### Final Status

**Day 37 — Docker Revision & Cheat Sheet: COMPLETED ✅**

> **Overall Docker confidence: 🟡 Good foundation, needs hands-on reinforcement in advanced areas.**

The main goal of Day 37 was to consolidate Days 29–36 and identify the Docker concepts that need more practical repetition before moving forward.
