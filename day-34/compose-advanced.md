# Day 34 -- Docker Compose: Real-World Multi-Container Apps

## Goal

Today we move from basic Docker Compose usage to a more realistic
multi-container application.


We will build a stack containing:
-   Flask web application
-   PostgreSQL database
-   Redis cache


Overview:
-   Custom Dockerfiles
-   `build:`
-   `depends_on`
-   Database healthchecks
-   `condition: service_healthy`
-   Restart policies
-   Explicit Docker networks
-   Named volumes
-   Service labels
-   Rebuilding containers
-   Scaling a service
-   Understanding port conflicts during scaling

------------------------------------------------------------------------

# 1. Project Structure

Commands:

``` bash
mkdir -p 2026/day-34/app
cd 2026/day-34
```

------------------------------------------------------------------------

# 2. Task 1 -- Build Your Own App Stack

Our stack:

  Service    Technology       Container Port
  ---------- -------------- ----------------
  Web        Python Flask               5000
  Database   PostgreSQL                 5432
  Cache      Redis                      6379

The Flask application will connect to both PostgreSQL and Redis.

------------------------------------------------------------------------

## 2.1 Create `requirements.txt`

Create:

``` text
app/requirements.txt
```

Add:

``` text
Flask==3.1.2
psycopg2-binary==2.9.10
redis==6.4.0
```

------------------------------------------------------------------------

## 2.2 Create the Flask application

Create:

``` text
app/app.py
```

Add:

``` python
import os
import time

import psycopg2
import redis
from flask import Flask

app = Flask(__name__)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "db"),
        database=os.getenv("POSTGRES_DB", "devops"),
        user=os.getenv("POSTGRES_USER", "devops"),
        password=os.getenv("POSTGRES_PASSWORD", "devops_password"),
    )


def get_redis_connection():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "redis"),
        port=6379,
        decode_responses=True,
    )


def initialize_database():
    for attempt in range(10):
        try:
            connection = get_db_connection()

            with connection:
                with connection.cursor() as cursor:
                    cursor.execute(
                        """
                        CREATE TABLE IF NOT EXISTS visits (
                            id SERIAL PRIMARY KEY,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        )
                        """
                    )

            connection.close()
            print("PostgreSQL is ready.")
            return

        except psycopg2.OperationalError as error:
            print(f"Database not ready yet: {error}")
            time.sleep(2)

    raise RuntimeError("Could not connect to PostgreSQL.")


@app.route("/")
def home():
    connection = get_db_connection()

    with connection:
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO visits DEFAULT VALUES")
            cursor.execute("SELECT COUNT(*) FROM visits")
            visit_count = cursor.fetchone()[0]

    connection.close()

    cache = get_redis_connection()
    cache.set("last_message", "Hello from Redis!")

    cached_message = cache.get("last_message")

    return f"""
    <h1>Day 34 - Docker Compose</h1>
    <p>Flask application is running.</p>
    <p>PostgreSQL visits: {visit_count}</p>
    <p>Redis message: {cached_message}</p>
    """


@app.route("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000)
```

### Important

Inside Docker Compose, services communicate using their service names.

Therefore:

``` text
db
```

is the PostgreSQL hostname, and:

``` text
redis
```

is the Redis hostname.

Do not use `localhost` for these connections from the web container.

------------------------------------------------------------------------

# 3. Create the Web App Dockerfile

Create:

``` text
app/Dockerfile
```

Add:

``` dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

What this does:

-   `FROM` selects Python as the base image.
-   `WORKDIR` sets `/app`.
-   `COPY requirements.txt` copies dependencies.
-   `RUN pip install` installs the dependencies.
-   `COPY app.py` copies the application.
-   `EXPOSE 5000` documents the application port.
-   `CMD` starts Flask.

------------------------------------------------------------------------

# 4. Create `docker-compose.yml`

Create:

``` text
docker-compose.yml
```

Add:

``` yaml
services:

  web:
    build: ./app
    container_name: day34-web
    ports:
      - "5000:5000"
    environment:
      POSTGRES_HOST: db
      POSTGRES_DB: devops
      POSTGRES_USER: devops
      POSTGRES_PASSWORD: devops_password
      REDIS_HOST: redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    labels:
      com.day: "34"
      com.project: "90daysofdevops"
      com.service: "web"

  db:
    image: postgres:16-alpine
    container_name: day34-db
    environment:
      POSTGRES_DB: devops
      POSTGRES_USER: devops
      POSTGRES_PASSWORD: devops_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U devops -d devops"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 5s
    networks:
      - app-network
    labels:
      com.day: "34"
      com.project: "90daysofdevops"
      com.service: "database"

  redis:
    image: redis:7-alpine
    container_name: day34-redis
    networks:
      - app-network
    labels:
      com.day: "34"
      com.project: "90daysofdevops"
      com.service: "cache"

networks:
  app-network:
    name: day34-app-network
    driver: bridge

volumes:
  postgres-data:
    name: day34-postgres-data
```

------------------------------------------------------------------------

# 5. Understand the Compose File

We have three services:

``` text
web
db
redis
```

## `build`

``` yaml
web:
  build: ./app
```

Compose builds the web image from:

``` text
app/Dockerfile
```

This satisfies the custom Dockerfile requirement.

## Port mapping

``` yaml
ports:
  - "5000:5000"
```

Means:

``` text
Host port 5000 → Container port 5000
```

The application is available at:

``` text
http://localhost:5000
```

------------------------------------------------------------------------

# 6. Task 2 -- `depends_on` and Healthchecks

We use:

``` yaml
depends_on:
  db:
    condition: service_healthy
```

This makes the web service wait until PostgreSQL passes its healthcheck.

This is better than simply:

``` yaml
depends_on:
  - db
```

because a container being started does not necessarily mean the
application inside it is ready.

------------------------------------------------------------------------

# 7. PostgreSQL Healthcheck

Our database contains:

``` yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U devops -d devops"]
  interval: 5s
  timeout: 5s
  retries: 5
  start_period: 5s
```

Meaning:

-   `test`: checks PostgreSQL readiness.
-   `interval`: checks every 5 seconds.
-   `timeout`: allows 5 seconds for a check.
-   `retries`: allows 5 failed checks.
-   `start_period`: gives PostgreSQL startup time.

------------------------------------------------------------------------

# 8. Start the Application

Run from:

``` text
2026/day-34/
```

``` bash
docker compose up --build
```

Compose will:

1.  Build the Flask image.
2.  Pull PostgreSQL.
3.  Pull Redis.
4.  Create the network.
5.  Create the volume.
6.  Start PostgreSQL.
7.  Run the PostgreSQL healthcheck.
8.  Start Redis.
9.  Start Flask after PostgreSQL becomes healthy.

------------------------------------------------------------------------

# 9. Check the Containers

Open another terminal:

``` bash
docker compose ps
```

Also:

``` bash
docker ps
```

You should have three services running.

------------------------------------------------------------------------

# 10. Test the Web Application

Open:

``` text
http://localhost:5000
```

Or:

``` bash
curl http://localhost:5000
```

Expected response:

``` text
Day 34 - Docker Compose
Flask application is running.
PostgreSQL visits: 1
Redis message: Hello from Redis!
```

Run it again:

``` bash
curl http://localhost:5000
```

The visit count should increase.

This proves the Flask application is communicating with PostgreSQL and
Redis.

------------------------------------------------------------------------

# 11. Check Database Health

Run:

``` bash
docker inspect day34-db --format='{{.State.Health.Status}}'
```

Expected:

``` text
healthy
```

You can also check:

``` bash
docker compose ps
```

------------------------------------------------------------------------

# 12. Test `depends_on` + Healthcheck

Stop everything:

``` bash
docker compose down
```

Start again:

``` bash
docker compose up
```

Watch the logs:

``` bash
docker compose logs -f
```

PostgreSQL starts first.

Docker performs the healthchecks.

After PostgreSQL becomes healthy, the web service starts.

### Important

`depends_on` controls startup dependency. It does not make the
application immune to future database failures. The application should
still handle connection errors.

------------------------------------------------------------------------

# 13. Task 3 -- Restart Policies

Our PostgreSQL service uses:

``` yaml
restart: always
```

This tells Docker to automatically restart the container if it stops.

------------------------------------------------------------------------

# 14. Test `restart: always`

Start the stack in the background:

``` bash
docker compose up -d
```

Check:

``` bash
docker ps
```

Kill PostgreSQL:

``` bash
docker kill day34-db
```

Then:

``` bash
docker ps
```

The PostgreSQL container should come back because of:

``` yaml
restart: always
```

Check the restart count:

``` bash
docker inspect day34-db --format='{{.RestartCount}}'
```

------------------------------------------------------------------------

# 15. Understand `restart: always`

``` yaml
restart: always
```

Use this when a service should continuously remain available and
automatically restart when it stops.

Examples:

-   Important backend services
-   Long-running services
-   Services that should recover automatically

------------------------------------------------------------------------

# 16. Test `restart: on-failure`

Change:

``` yaml
restart: always
```

to:

``` yaml
restart: on-failure
```

Then recreate the database:

``` bash
docker compose up -d --force-recreate db
```

`on-failure` is intended to restart a container when its process exits
with a failure.

It differs from `always`, which is designed to restart the container
whenever it stops.

------------------------------------------------------------------------

# 17. Restart Policy Comparison

  Policy             Meaning
  ------------------ --------------------------------------
  `no`               No automatic restart
  `always`           Restart whenever the container stops
  `on-failure`       Restart after a failure exit
  `unless-stopped`   Restart unless explicitly stopped

### When would I use each?

**`always`** --- services that should stay available.

**`on-failure`** --- applications where unexpected process failures
should trigger recovery.

**`unless-stopped`** --- long-running services where automatic recovery
is wanted but an intentional manual stop should remain stopped.

**`no`** --- development/debugging where automatic restarts are not
wanted.

After the experiment, restore:

``` yaml
restart: always
```

------------------------------------------------------------------------

# 18. Task 4 -- Custom Dockerfiles in Compose

We already use:

``` yaml
build: ./app
```

Compose builds the application image from our Dockerfile instead of
using a pre-built web image.

------------------------------------------------------------------------

# 19. Make a Code Change

Open:

``` text
app/app.py
```

Change:

``` html
<h1>Day 34 - Docker Compose</h1>
```

to:

``` html
<h1>Day 34 - Docker Compose Advanced!</h1>
```

Save the file.

Rebuild and restart:

``` bash
docker compose up --build -d
```

This rebuilds the image and recreates/starts the required containers.

------------------------------------------------------------------------

# 20. Verify the Code Change

Run:

``` bash
curl http://localhost:5000
```

You should see the updated message.

------------------------------------------------------------------------

# 21. Task 5 -- Named Networks

We explicitly define:

``` yaml
networks:
  app-network:
    name: day34-app-network
    driver: bridge
```

Every service uses:

``` yaml
networks:
  - app-network
```

Architecture:

``` text
day34-app-network

web
 │
 ├── db
 │
 └── redis
```

------------------------------------------------------------------------

# 22. Why Use a Custom Network?

Compose automatically creates a default network, but explicitly defining
one makes the architecture clear and gives us control over the network
configuration.

Services can communicate using their service names:

``` text
db
redis
```

------------------------------------------------------------------------

# 23. Inspect the Network

Run:

``` bash
docker network ls
```

Look for:

``` text
day34-app-network
```

Inspect it:

``` bash
docker network inspect day34-app-network
```

You should see the containers connected to it.

------------------------------------------------------------------------

# 24. Named Volumes

PostgreSQL uses:

``` yaml
volumes:
  - postgres-data:/var/lib/postgresql/data
```

And the named volume is defined as:

``` yaml
volumes:
  postgres-data:
    name: day34-postgres-data
```

This gives PostgreSQL persistent storage.

------------------------------------------------------------------------

# 25. Why Do We Need a Volume?

Without persistent storage, important database data is tied to the
container lifecycle.

With a named volume:

``` text
PostgreSQL container
       ↓
/var/lib/postgresql/data
       ↓
day34-postgres-data
```

The data can survive removal and recreation of the container.

------------------------------------------------------------------------

# 26. Verify the Volume

Run:

``` bash
docker volume ls
```

Look for:

``` text
day34-postgres-data
```

Inspect:

``` bash
docker volume inspect day34-postgres-data
```

------------------------------------------------------------------------

# 27. Test Database Persistence

Start the stack:

``` bash
docker compose up -d
```

Run:

``` bash
curl http://localhost:5000
```

Note the visit count.

For example:

``` text
PostgreSQL visits: 5
```

Remove the containers:

``` bash
docker compose down
```

Start again:

``` bash
docker compose up -d
```

Run:

``` bash
curl http://localhost:5000
```

The count should continue from the previous value.

That demonstrates persistent database storage.

------------------------------------------------------------------------

# 28. Important: `docker compose down -v`

Be careful with:

``` bash
docker compose down -v
```

The `-v` option removes the Compose volumes.

That can delete our PostgreSQL data.

For normal testing where data should remain, use:

``` bash
docker compose down
```

------------------------------------------------------------------------

# 29. Service Labels

Each service has labels such as:

``` yaml
labels:
  com.day: "34"
  com.project: "90daysofdevops"
  com.service: "web"
```

Labels are metadata attached to Docker resources.

They can help with:

-   Organization
-   Automation
-   Filtering
-   Monitoring
-   Management

------------------------------------------------------------------------

# 30. Check Labels

Run:

``` bash
docker inspect day34-web --format='{{json .Config.Labels}}'
```

You should see the labels.

------------------------------------------------------------------------

# 31. Task 6 -- Scaling

Start the stack:

``` bash
docker compose up -d
```

Now try:

``` bash
docker compose up --scale web=3 -d
```

------------------------------------------------------------------------

# 32. What Happens?

The web service contains:

``` yaml
ports:
  - "5000:5000"
```

If three web replicas are created, each tries to bind the same host
port:

``` text
web-1 → host 5000
web-2 → host 5000
web-3 → host 5000
```

A host port cannot simply be bound by multiple containers at the same
time.

Therefore the additional replicas cannot all use:

``` text
5000:5000
```

and Compose will report a port-binding conflict.

------------------------------------------------------------------------

# 33. Why Does Port Mapping Break Scaling?

This:

``` yaml
ports:
  - "5000:5000"
```

means:

``` text
Host:5000 → Container:5000
```

Three replicas would all request:

``` text
Host:5000
```

That creates a conflict.

In a production architecture, multiple application replicas are normally
placed behind a:

-   Load balancer
-   Reverse proxy
-   Ingress controller
-   Service discovery mechanism

Example:

``` text
                    ┌──────────────┐
Internet ──────────►│ Load Balancer│
                    └──────┬───────┘
                           │
                ┌──────────┼──────────┐
                │          │          │
              web-1      web-2      web-3
                │          │          │
                └──────────┼──────────┘
                           │
                      PostgreSQL
```

------------------------------------------------------------------------

# 34. Stop the Scaling Experiment

Run:

``` bash
docker compose down
```

Then:

``` bash
docker compose up -d
```

Check:

``` bash
docker compose ps
```

Return to the normal three-service setup.

------------------------------------------------------------------------

# 35. Useful Docker Compose Commands

Start:

``` bash
docker compose up
```

Start in background:

``` bash
docker compose up -d
```

Build and start:

``` bash
docker compose up --build
```

Build and start in background:

``` bash
docker compose up --build -d
```

Stop/remove containers:

``` bash
docker compose down
```

View services:

``` bash
docker compose ps
```

View logs:

``` bash
docker compose logs
```

Follow logs:

``` bash
docker compose logs -f
```

Service-specific logs:

``` bash
docker compose logs web
docker compose logs db
docker compose logs redis
```

Restart:

``` bash
docker compose restart web
```

Build:

``` bash
docker compose build
```

Scale:

``` bash
docker compose up --scale web=3
```

------------------------------------------------------------------------

# 36. Useful Debugging Commands

Running containers:

``` bash
docker ps
```

All containers:

``` bash
docker ps -a
```

Inspect PostgreSQL:

``` bash
docker inspect day34-db
```

Inspect web:

``` bash
docker inspect day34-web
```

Check database health:

``` bash
docker inspect day34-db --format='{{.State.Health.Status}}'
```

Inspect network:

``` bash
docker network inspect day34-app-network
```

Inspect volume:

``` bash
docker volume inspect day34-postgres-data
```

------------------------------------------------------------------------

# 37. Test Container-to-Container Communication

The web application connects to PostgreSQL using:

``` text
db:5432
```

and Redis using:

``` text
redis:6379
```

Docker Compose provides DNS for service names.

Important:

``` text
web container
     │
     ├── db:5432
     │
     └── redis:6379
```

Do not use:

``` text
localhost:5432
localhost:6379
```

inside the web container.

Inside the web container, `localhost` refers to the web container
itself.

------------------------------------------------------------------------

# 38. Full Clean Test

After completing all tasks:

``` bash
docker compose down
```

Then:

``` bash
docker compose up --build -d
```

Check:

``` bash
docker compose ps
```

Check logs:

``` bash
docker compose logs
```

Check PostgreSQL health:

``` bash
docker inspect day34-db --format='{{.State.Health.Status}}'
```

Expected:

``` text
healthy
```

Test the application:

``` bash
curl http://localhost:5000
```

Test the health endpoint:

``` bash
curl http://localhost:5000/health
```

Expected:

``` text
OK
```
------------------------------------------------------------------------

# 39. Key Concepts Learned

## Docker Compose

Docker Compose lets us define and manage multiple related containers as
one application stack.

Instead of manually running multiple `docker run` commands, we define
everything in:

``` text
docker-compose.yml
```

and run:

``` bash
docker compose up
```

## `depends_on`

Controls startup dependencies:

``` yaml
depends_on:
  db:
    condition: service_healthy
```

## Healthcheck

Checks whether a service is actually ready.

A container being `running` does not necessarily mean the application
inside it is ready.

## Restart Policies

Important policies:

``` text
no
always
on-failure
unless-stopped
```

## Named Volume

Provides persistent storage independent of the container lifecycle.

## Network

Allows containers to communicate using service names such as:

``` text
db
redis
```

## Labels

Add metadata useful for organization, automation and management.

## Scaling

Compose can create multiple replicas:

``` bash
docker compose up --scale web=3
```

but direct host port mapping can prevent multiple replicas from
starting.

------------------------------------------------------------------------

# 40. Final Architecture

``` text
                         Host
                          │
                    localhost:5000
                          │
                          ▼
                  ┌───────────────┐
                  │  Flask Web    │
                  │   Container   │
                  └───────┬───────┘
                          │
                   day34-app-network
                     ┌────┴────┐
                     │         │
                     ▼         ▼
              ┌───────────┐ ┌───────────┐
              │ PostgreSQL│ │   Redis   │
              │   :5432   │ │   :6379   │
              └─────┬─────┘ └───────────┘
                    │
                    ▼
             day34-postgres-data
                named volume
```

------------------------------------------------------------------------

# 41. Final Summary

Today we moved from simply running containers to managing a small
application architecture.

The mental model is:

``` text
Docker
  ↓
Containers
  ↓
Docker Compose
  ↓
Multiple related containers
  ↓
Networks + Volumes + Healthchecks
  ↓
Dependencies + Restart Policies
  ↓
Scaling
```

The biggest lessons:

1.  A running container is not necessarily a ready application.
2.  Healthchecks can tell Compose when a service is actually ready.
3.  `depends_on` can control startup dependencies.
4.  Restart policies help services recover automatically.
5.  Named volumes keep important data outside the container lifecycle.
6.  Networks allow services to communicate using service names.
7.  Custom Dockerfiles let Compose build our own application images.
8.  Scaling requires thinking about networking and traffic routing.
9.  Host port mappings can prevent simple horizontal scaling.
10. Production systems commonly put a load balancer or reverse proxy in
    front of multiple application replicas.

------------------------------------------------------------------------


Keep learning. Keep building. 🚀
