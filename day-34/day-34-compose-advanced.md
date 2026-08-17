# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Challenge Tasks

### Task 1: Build Your Own App Stack

Created a 3-service Docker Compose stack:

- A **web app** using Python Flask
- A **database** using PostgreSQL
- A **cache** using Redis

The architecture:

```text
                Flask Web App
                     |
             -----------------
             |               |
        PostgreSQL          Redis
        Database            Cache
```

Flask connects to PostgreSQL using the service name `db` and Redis using the service name `redis`.

[Code](web_db_cache/)

---

### Task 2: depends_on & Healthchecks

1. Added `depends_on` so the Flask app starts after the required services.
2. Added a PostgreSQL healthcheck.
3. Used `condition: service_healthy` so Flask waits until PostgreSQL is actually ready.

```yaml
depends_on:
  db:
    condition: service_healthy
  redis:
    condition: service_started
```

PostgreSQL healthcheck:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U devops -d devops"]
  interval: 5s
  timeout: 5s
  retries: 5
  start_period: 5s
```

**Test:** Bring everything down and up.

```bash
sudo docker compose down
sudo docker compose up
```

- PostgreSQL container starts.
- PostgreSQL healthcheck runs.
- PostgreSQL becomes `healthy`.
- Redis starts.
- Flask starts after the required dependency conditions are satisfied.

Check PostgreSQL health:

```bash
sudo docker inspect day34-db --format='{{.State.Health.Status}}'
```

Expected:

```text
healthy
```

![image](images/task2down.png)

![image](images/task2log.png)

---

### Task 3: Restart Policies

#### 1. `restart: always`

Added:

```yaml
restart: always
```

to the PostgreSQL service.

For testing, temporarily used:

```yaml
restart: always
entrypoint: ["/bin/sh", "-c"]
command: ["exit 0"]
```

Then:

```bash
sudo docker compose up -d --force-recreate db
```

Checked:

```bash
sudo docker inspect day34-db --format='Status={{.State.Status}} ExitCode={{.State.ExitCode}} RestartCount={{.RestartCount}}'
```

With `restart: always`, Docker keeps restarting the container even when the process exits successfully with exit code `0`.

![image](images/task3.1.png)

> Note: Manually using `docker kill day34-db` is not a reliable test for observing an automatic restart because manually stopped containers are not immediately restarted in the same way as containers whose main process exits.

#### 2. `restart: on-failure`

Changed:

```yaml
restart: always
```

to:

```yaml
restart: on-failure
```

For testing, temporarily used:

```yaml
restart: on-failure
entrypoint: ["/bin/sh", "-c"]
command: ["exit 1"]
```

Then:

```bash
sudo docker compose up -d --force-recreate db
```

Checked:

```bash
sudo docker inspect day34-db --format='Status={{.State.Status}} ExitCode={{.State.ExitCode}} RestartCount={{.RestartCount}}'
```

Because the process exits with a non-zero exit code, `on-failure` restarts the container.

![image](images/task3.2.png)

#### 3. Difference between `always` and `on-failure`

```text
restart: always
        ↓
Restart regardless of exit status

restart: on-failure
        ↓
Restart only when the process exits with failure
```

| Policy | Use When |
|---|---|
| `restart: always` | Databases, backend APIs, production services, services that should keep running |
| `restart: on-failure` | Data processing jobs, batch jobs, applications where only failures should trigger a restart |
| `restart: unless-stopped` | Long-running services that should restart automatically unless manually stopped |
| `restart: no` | Development/debugging where automatic restart is not required |

After testing, restored:

```yaml
restart: always
```

---

### Task 4: Custom Dockerfiles in Compose

Instead of using a pre-built image for the Flask application, used:

```yaml
build: ./app
```

This tells Docker Compose to build the web image using:

```text
app/Dockerfile
```

[Dockerfile](web_db_cache/app/Dockerfile)

Before making the change:

![image](images/before.png)

Made a code change in `app.py`.

Then rebuilt and restarted with:

```bash
sudo docker compose up --build -d
```

After the code change:

![image](images/aftercodechange.png)

The updated application was running using the newly built image.

[Compose](web_db_cache/docker-compose.yml)

---

### Task 5: Named Networks & Volumes

#### 1. Custom Network

Defined an explicit Docker network:

```yaml
networks:
  app-network:
    name: day34-app-network
    driver: bridge
```

All three services use this network:

```yaml
networks:
  - app-network
```

Check it with:

```bash
sudo docker network ls
```

And:

```bash
sudo docker network inspect day34-app-network
```

#### 2. Named Volume

Created a named volume for PostgreSQL:

```yaml
volumes:
  - postgres-data:/var/lib/postgresql/data
```

Defined it as:

```yaml
volumes:
  postgres-data:
    name: day34-postgres-data
```

Check it with:

```bash
sudo docker volume ls
```

This allows PostgreSQL data to survive container recreation.

Tested using:

```bash
sudo docker compose down
sudo docker compose up -d
```

The PostgreSQL visit count remained because the named volume preserved the database data.

> Do not use `docker compose down -v` when testing persistence because `-v` removes the volumes.

#### 3. Labels

Added labels to the services:

```yaml
labels:
  com.day: "34"
  com.project: "90daysofdevops"
  com.service: "web"
```

Checked using:

```bash
sudo docker inspect day34-web --format='{{json .Config.Labels}}'
```

Labels provide metadata useful for organization, filtering and automation.

[Compose](web_db_cache/docker-compose.yml)

---

### Task 6: Scaling

Tried scaling the Flask web application to 3 replicas:

```bash
sudo docker compose up --scale web=3 -d
```

The web service uses:

```yaml
ports:
  - "5000:5000"
```

This means:

```text
Host port 5000 → Container port 5000
```

When scaling to 3 replicas:

```text
web-1 → host port 5000
web-2 → host port 5000
web-3 → host port 5000
```

The first container started successfully.

The second and third containers could not bind to host port `5000` because it was already in use.

![image](images/task6.1.png)

![image](images/task6.2.png)

### What breaks?

The host port mapping causes a conflict.

Docker cannot bind multiple containers to the same host port:

```text
5000:5000
```

### Why doesn't simple scaling work with port mapping?

Because all replicas try to claim the same host port.

In a production setup, multiple application replicas would normally sit behind a load balancer or reverse proxy:

```text
                 Load Balancer
                       |
              -------------------
              |        |        |
            web-1    web-2    web-3
```

After the scaling experiment:

```bash
sudo docker compose down
sudo docker compose up -d
```

Returned to the normal 3-service setup.

---

## Final Architecture

```text
                         Host
                          |
                    localhost:5000
                          |
                          v
                  +---------------+
                  |   Flask Web   |
                  +-------+-------+
                          |
                  day34-app-network
                    +-----+-----+
                    |           |
                    v           v
              +-----------+ +---------+
              | PostgreSQL| |  Redis  |
              | Database  | |  Cache  |
              +-----+-----+ +---------+
                    |
                    v
             day34-postgres-data
                named volume
```

## What I Learned

- Docker Compose can manage multiple related containers as one application.
- Flask acts as the web application.
- PostgreSQL stores persistent application data.
- Redis provides fast cache data.
- `depends_on` controls service startup dependencies.
- A healthcheck verifies that PostgreSQL is actually ready.
- `condition: service_healthy` makes Flask wait for PostgreSQL readiness.
- Restart policies can automatically recover containers.
- `restart: always` and `restart: on-failure` behave differently.
- Named volumes preserve database data.
- Custom networks allow containers to communicate using service names.
- Labels add useful metadata to Docker services.
- `build:` allows Compose to build an application from a custom Dockerfile.
- Simple scaling fails when multiple replicas try to use the same host port.
- Load balancers/reverse proxies are commonly used to distribute traffic across replicas.

---
