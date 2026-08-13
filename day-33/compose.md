# Day 33 – Docker Compose: Multi-Container Basics

## Goal

Run multi-container applications with a single command using Docker Compose.

Yesterday, containers, networks, and volumes were created manually. Today, Docker Compose puts that configuration into YAML so the whole application can be started and stopped with simple commands.

---

## Task 1 – Install & Verify

### 1. Check whether Docker is installed

```bash
docker --version
```

Expected format:

```text
Docker version XX.X.X, build XXXXXXX
```

### 2. Verify Docker Compose

Modern Docker uses Compose as a Docker CLI plugin:

```bash
docker compose version
```

Expected format:

```text
Docker Compose version v2.x.x
```

> Use `docker compose`, not the older `docker-compose`, for current Docker installations.

---

# Task 2 – Your First Compose File

## 1. Create the project directory

```bash
mkdir -p compose-basics
cd compose-basics
```

## 2. Create `docker-compose.yml`

The file is included with this Day 33 submission.

It runs one Nginx container and maps:

```text
Host port 8080 → Container port 80
```

## 3. Validate the Compose file

```bash
docker compose config
```

If the YAML is valid, Compose prints the resolved configuration.

## 4. Start Nginx

```bash
docker compose up -d
```

`-d` means detached mode, so the terminal is returned immediately.

## 5. Check the running service

```bash
docker compose ps
```

Expected state:

```text
nginx    ...    Up
```

## 6. Access Nginx

If running on an EC2 instance, open:

```text
http://<EC2-PUBLIC-IP>:8080
```

Make sure the EC2 security group allows inbound TCP port `8080`.

You can also test from the EC2 terminal:

```bash
curl http://localhost:8080
```

You should receive the Nginx HTML response.

## 7. View logs

```bash
docker compose logs
```

Follow logs live:

```bash
docker compose logs -f
```

## 8. Stop and remove the application

```bash
docker compose down
```

This removes the Compose-created container and network.

---

# Task 3 – Two-Container Setup

Now create a WordPress + MySQL application.

Architecture:

```text
Browser
   |
   | HTTP :8080
   v
WordPress container
   |
   | db:3306
   v
MySQL container
   |
   v
mysql_data volume
```

Compose automatically creates a default network for the services.

The important point is that WordPress connects to MySQL using the **service name**:

```text
db:3306
```

`db` is the Compose service name, so Docker's internal DNS resolves `db` to the MySQL container.

## 1. Create the project directory

```bash
mkdir -p wordpress-mysql
cd wordpress-mysql
```

## 2. Create `docker-compose.yml`

The included file defines two services:

- `db` → MySQL
- `wordpress` → WordPress

It also defines:

- `mysql_data` → persistent MySQL data
- `wordpress_data` → persistent WordPress files

## 3. Create `.env`

The included `.env` file contains the database variables used by Compose.

Example:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=change_this_password
MYSQL_ROOT_PASSWORD=change_this_root_password
```

### Important

Do not commit real passwords to GitHub.

For a real project, add `.env` to `.gitignore`:

```bash
echo ".env" >> .gitignore
```

## 4. Validate the configuration

```bash
docker compose config
```

This is especially useful because it shows the values after Compose processes the `.env` variables.

## 5. Start both containers

```bash
docker compose up -d
```

Compose will:

1. Create the network.
2. Pull the MySQL image if necessary.
3. Pull the WordPress image if necessary.
4. Create the MySQL container.
5. Create the WordPress container.
6. Create the named volumes.
7. Start both services.

## 6. Check services

```bash
docker compose ps
```

Both `db` and `wordpress` should be running.

## 7. Check the network

```bash
docker network ls
```

Compose creates a project-specific default network automatically.

You can inspect it with:

```bash
docker network inspect wordpress-mysql_default
```

The exact network name can vary depending on the directory/project name.

## 8. Check the volumes

```bash
docker volume ls
```

You should see Compose-created volumes for the project, including the MySQL data volume.

## 9. Access WordPress

On an EC2 instance:

```text
http://<EC2-PUBLIC-IP>:8080
```

Open the WordPress setup page and complete the installation.

For the database connection, WordPress receives the database settings from the Compose environment variables.

The database host is:

```text
db:3306
```

Do **not** use:

```text
localhost
```

because `localhost` inside the WordPress container means the WordPress container itself, not MySQL.

---

# Verify Data Persistence

After completing the WordPress setup, create a test post such as:

```text
Docker Compose Day 33
```

Then stop the application:

```bash
docker compose down
```

Start it again:

```bash
docker compose up -d
```

Open WordPress again:

```text
http://<EC2-PUBLIC-IP>:8080
```

The WordPress database information, users, posts, settings, etc. should still exist because MySQL stores its data in the named volume:

```text
mysql_data
```

The WordPress files are also mounted to:

```text
wordpress_data
```

### Important difference

`docker compose down` removes containers and the Compose network, but it does **not** remove named volumes by default.

Therefore:

```bash
docker compose down
```

keeps the database volume.

But:

```bash
docker compose down -v
```

also removes the named volumes and therefore deletes the persisted database data.

---

# Task 4 – Compose Commands

## Start services in detached mode

```bash
docker compose up -d
```

## View running services

```bash
docker compose ps
```

## View logs of all services

```bash
docker compose logs
```

## Follow logs of all services

```bash
docker compose logs -f
```

Press `Ctrl+C` to stop following the logs.

## View logs of a specific service

For WordPress:

```bash
docker compose logs wordpress
```

Follow WordPress logs:

```bash
docker compose logs -f wordpress
```

For MySQL:

```bash
docker compose logs db
```

## Stop services without removing them

```bash
docker compose stop
```

This stops the containers but keeps them.

Start them again:

```bash
docker compose start
```

## Remove containers and networks

```bash
docker compose down
```

This removes the Compose containers and network.

Named volumes are kept.

## Remove containers, networks and volumes

```bash
docker compose down -v
```

**Warning:** this deletes the named volumes created by the Compose project.

For this WordPress setup, that means the MySQL data is deleted.

## Rebuild images after making changes

For services with a Dockerfile/build configuration:

```bash
docker compose build
```

Then:

```bash
docker compose up -d
```

Or rebuild and start in one command:

```bash
docker compose up -d --build
```

For this Day 33 exercise, the services use pre-built Docker Hub images, so normally there is nothing to rebuild unless the Compose configuration is changed to use a custom `build:` context.

---

# Task 5 – Environment Variables

Docker Compose supports environment variables directly in the YAML and through a `.env` file.

## Method 1 – Variables directly in `docker-compose.yml`

Example:

```yaml
environment:
  MYSQL_DATABASE: wordpress
  MYSQL_USER: wordpress_user
  MYSQL_PASSWORD: example_password
  MYSQL_ROOT_PASSWORD: example_root_password
```

This is simple for testing, but putting passwords directly in the Compose file is not ideal for real projects.

## Method 2 – Use a `.env` file

Create:

```text
.env
```

Example:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=change_this_password
MYSQL_ROOT_PASSWORD=change_this_root_password
```

Then reference those values from `docker-compose.yml`:

```yaml
environment:
  MYSQL_DATABASE: ${MYSQL_DATABASE}
  MYSQL_USER: ${MYSQL_USER}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

Compose automatically reads `.env` from the project directory.

## Verify the variables

Run:

```bash
docker compose config
```

The rendered configuration should show the resolved environment values.

You can also inspect the running container:

```bash
docker compose exec db env
```

Or filter for MySQL variables:

```bash
docker compose exec db env | grep MYSQL
```

For WordPress:

```bash
docker compose exec wordpress env | grep WORDPRESS
```

---

# Useful Compose Commands Cheat Sheet

| Command | Purpose |
|---|---|
| `docker compose up` | Start services in foreground |
| `docker compose up -d` | Start services in background |
| `docker compose up -d --build` | Rebuild and start |
| `docker compose ps` | Show service status |
| `docker compose logs` | Show logs |
| `docker compose logs -f` | Follow all logs |
| `docker compose logs -f wordpress` | Follow one service |
| `docker compose stop` | Stop services |
| `docker compose start` | Start stopped services |
| `docker compose restart` | Restart services |
| `docker compose down` | Remove containers and network |
| `docker compose down -v` | Remove containers, network and volumes |
| `docker compose config` | Validate/render Compose configuration |
| `docker compose build` | Build images |

---

# What I Learned Today

- Docker Compose lets multiple containers be defined in one YAML file.
- `docker compose up -d` can start an entire application with one command.
- Compose automatically creates a network for services in the same project.
- Services can communicate using their Compose service names.
- WordPress can reach MySQL using `db:3306`.
- Named volumes keep data when containers are removed.
- `docker compose down` does not remove named volumes by default.
- `docker compose down -v` removes named volumes and their data.
- `.env` files can keep configuration values outside the main Compose YAML.
- `docker compose config` is useful for validating and inspecting the final configuration.
- Compose makes multi-container application setup reproducible and easier to manage.

---

# Day 33 Verification Checklist

- [ ] Verified Docker installation.
- [ ] Verified Docker Compose version.
- [ ] Created `compose-basics`.
- [ ] Created Nginx `docker-compose.yml`.
- [ ] Started Nginx with `docker compose up -d`.
- [ ] Accessed Nginx on port `8080`.
- [ ] Stopped Nginx with `docker compose down`.
- [ ] Created WordPress + MySQL Compose setup.
- [ ] Started both services.
- [ ] Verified the Compose network.
- [ ] Accessed WordPress.
- [ ] Completed WordPress setup.
- [ ] Created test WordPress data.
- [ ] Ran `docker compose down`.
- [ ] Ran `docker compose up -d`.
- [ ] Verified WordPress data persisted.
- [ ] Practiced Compose logs.
- [ ] Practiced `stop` and `start`.
- [ ] Practiced `down`.
- [ ] Practiced `down -v` carefully.
- [ ] Practiced `docker compose config`.
- [ ] Tested environment variables.
- [ ] Created a `.env` file.
- [ ] Learned the difference between `down` and `down -v`.

# Final Takeaway

Before Docker Compose:

```text
Create network
      ↓
Create volume
      ↓
Run MySQL
      ↓
Run WordPress
      ↓
Connect containers manually
```

With Docker Compose:

```text
docker-compose.yml
      ↓
docker compose up -d
      ↓
Network + Volumes + Containers
      ↓
Application Running
```

Docker Compose turns multi-container configuration into **configuration as code** — making the application easier to start, stop, reproduce, and share.
