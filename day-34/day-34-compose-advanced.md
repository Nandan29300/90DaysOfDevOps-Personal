# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Challenge Tasks

### Task 1: Build Your Own App Stack

Created a 3-service Docker Compose stack:

- A **web app** using Node.js and Express
- A **database** using PostgreSQL
- A **cache** using Redis

The architecture:

```text
                 Node.js App
                     |
             -----------------
             |               |
        PostgreSQL          Redis
        Database            Cache
```

The Node.js app connects to PostgreSQL using the service name `db` and Redis using the service name `redis`.

[Code](web-db-cache/)

---

### Task 2: depends_on & Healthchecks

1. Added `depends_on` so the app starts after PostgreSQL is healthy.
2. Added a PostgreSQL healthcheck.
3. Used `condition: service_healthy` so the app waits until PostgreSQL is truly ready.

```yaml
depends_on:
  db:
    condition: service_healthy
```

PostgreSQL healthcheck:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 10s
```

**Test:** Bring everything down and up.

```bash
sudo docker compose down
sudo docker compose up
```

- PostgreSQL container starts first.
- PostgreSQL healthcheck runs.
- PostgreSQL becomes `healthy`.
- App container starts after PostgreSQL is healthy.
- Redis starts as part of the Compose stack.

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

Then recreated the database:

```bash
sudo docker compose up -d --force-recreate db
```

Checked:

```bash
sudo docker inspect day34-db --format='Status={{.State.Status}} ExitCode={{.State.ExitCode}} RestartCount={{.RestartCount}}'
```

With `restart: always`, Docker restarts the container even when the process exits successfully with exit code `0`.

![image](images/task3.1.png)

> Note: `docker kill day34-db` is not a reliable way to observe the restart policy because a manually stopped container is not immediately restarted in the same way as a container whose main process exits.

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

Then recreated the database:

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

Instead of using a pre-built image for the Node.js application, used:

```yaml
build:
  context: ./app
  dockerfile: Dockerfile
```

This tells Docker Compose to build the application using:

```text
app/Dockerfile
```

The application uses a Node.js Alpine image and installs its dependencies from `package.json`.

[Dockerfile](web_db_cache/app/Dockerfile)

Before making the code change:

![image](images/before.png)

Made a code change in `app/index.js`.

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

Defined an explicit Docker network instead of relying on the default network:

```yaml
networks:
  3-tier:
    driver: bridge
```

All three services use this network:

```yaml
networks:
  - 3-tier
```

This allows the services to communicate using their Compose service names:

```text
db:5432
redis:6379
```

Check it with:

```bash
sudo docker network ls
```

And:

```bash
sudo docker network inspect day-34-3-tier
```

---

#### 2. Named Volume

Created a named volume for PostgreSQL:

```yaml
volumes:
  - db_data:/var/lib/postgresql/data
```

Defined it as:

```yaml
volumes:
  db_data:
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

---

#### 3. Labels

Added labels to the services:

```yaml
labels:
  tier: "database"
```

```yaml
labels:
  tier: "cache"
```

```yaml
labels:
  tier: "web"
```

Checked using:

```bash
sudo docker inspect day34-web --format='{{json .Config.Labels}}'
```

Labels provide metadata useful for organization, filtering and automation.

[Compose](web_db_cache/docker-compose.yml)

---

### Task 6: Scaling

Tried scaling the Node.js web application to 3 replicas:

```bash
sudo docker compose up --scale app=3 -d
```

The app service uses:

```yaml
ports:
  - "${APP_PORT}:3000"
```

For example, if:

```text
APP_PORT=5000
```

then:

```text
Host port 5000 → Container port 3000
```

When scaling to 3 replicas:

```text
app-1 → host port 5000
app-2 → host port 5000
app-3 → host port 5000
```

The first container started successfully.

The second and third containers could not bind to host port `5000` because it was already in use.

![image](images/task6.1.png)

![image](images/task6.2.png)

### What breaks?

The host port mapping causes a conflict.

Docker cannot bind multiple containers to the same host port:

```text
5000:3000
```

### Why doesn't simple scaling work with port mapping?

Because all replicas try to claim the same host port.

In a production setup, multiple application replicas would normally sit behind a load balancer or reverse proxy:

```text
                 Load Balancer
                       |
              -------------------
              |        |        |
            app-1    app-2    app-3
```

The load balancer distributes incoming traffic between the application replicas.

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
                  |   Node.js App |
                  |    Express    |
                  +-------+-------+
                          |
                       3-tier
                    +-----+-----+
                    |           |
                    v           v
              +-----------+ +---------+
              | PostgreSQL| |  Redis  |
              | Database  | |  Cache  |
              +-----+-----+ +---------+
                    |
                    v
                  db_data
                named volume
```

## What I Learned

- Docker Compose can manage multiple related containers as one application.
- Node.js and Express act as the web application.
- PostgreSQL stores persistent application data.
- Redis provides fast cache data.
- `depends_on` controls service startup dependencies.
- A healthcheck verifies that PostgreSQL is actually ready.
- `condition: service_healthy` makes the app wait for PostgreSQL readiness.
- Restart policies can automatically recover containers.
- `restart: always` and `restart: on-failure` behave differently.
- Named volumes preserve database data.
- Custom networks allow containers to communicate using service names.
- Labels add useful metadata to Docker services.
- `build:` allows Compose to build an application from a custom Dockerfile.
- `package.json` defines the Node.js application dependencies.
- Simple scaling fails when multiple replicas try to use the same host port.
- Load balancers/reverse proxies are commonly used to distribute traffic across replicas.

---
