# Day 29 – Introduction to Docker

## Objective

The goal of Day 29 is to understand the fundamentals of Docker, learn why containers are important, install Docker, and run your first containers. By the end of this task, you will have a solid understanding of Docker basics and the commands used to manage containers.

---

# Task 1: What is Docker?

## What is Docker?

Docker is an open-source containerization platform that allows developers to package an application along with all its dependencies, libraries, runtime, and configuration into a **container**.

A Docker container runs consistently across different environments, ensuring that an application behaves the same whether it is running on a developer's laptop, a testing server, or in production.

Simply put:

> **"Build once, run anywhere."**

---

## What is a Container?

A **container** is a lightweight, isolated environment that packages an application together with everything it needs to run.

A container includes:

- Application source code
- Runtime
- Libraries
- Dependencies
- Environment variables
- Configuration files

Unlike a Virtual Machine, a container **does not contain a full operating system**. Instead, it shares the host operating system's kernel, making it much smaller and faster.

---

## Why Do We Need Containers?

Before containers, applications often worked perfectly on one machine but failed on another because of differences in:

- Installed software
- Library versions
- Runtime versions
- Environment configuration
- Operating system differences

This commonly led to the famous problem:

> **"It works on my machine."**

Containers solve this problem by packaging everything required for the application, making it portable and reproducible across all environments.

### Benefits of Containers

- Lightweight
- Portable
- Fast startup
- Consistent environments
- Efficient resource utilization
- Easy scaling
- Simplifies deployments
- Ideal for microservices
- Works seamlessly with CI/CD pipelines

---

# Containers vs Virtual Machines

| Feature | Containers | Virtual Machines |
|----------|------------|------------------|
| Virtualization | OS-level | Hardware-level |
| Guest Operating System | Not required | Required |
| Startup Time | Seconds | Minutes |
| Size | MBs | GBs |
| Performance | Near-native | Slightly slower |
| Resource Usage | Low | High |
| Isolation | Process-level | Full machine isolation |
| Kernel | Shares host kernel | Own kernel |

### Virtual Machine

A Virtual Machine virtualizes the hardware. Every VM contains:

- Full operating system
- Own kernel
- Applications
- Dependencies

Because every VM includes an entire OS, they consume more memory and storage.

---

### Container

A container virtualizes the operating system.

It shares the host OS kernel while keeping applications isolated.

This makes containers:

- Smaller
- Faster
- More efficient
- Easier to deploy

---

# Docker Architecture

Docker follows a **Client–Server Architecture**.

It consists of four main components:

- Docker Client
- Docker Daemon
- Docker Registry
- Docker Images & Containers

---

## 1. Docker Client

The Docker Client is the command-line interface (CLI) that users interact with.

Whenever you execute commands like:

```bash
docker run
docker pull
docker ps
docker images
```

the Docker Client sends these requests to the Docker Daemon.

---

## 2. Docker Daemon

The Docker Daemon (`dockerd`) is the background service responsible for managing Docker.

It performs operations such as:

- Building images
- Pulling images
- Running containers
- Stopping containers
- Removing containers
- Managing Docker networks
- Managing Docker volumes

The daemon performs the actual work after receiving requests from the Docker Client.

---

## 3. Docker Registry

A Docker Registry stores Docker images.

The default public registry is:

**Docker Hub**

It contains thousands of ready-to-use images like:

- Ubuntu
- Nginx
- MySQL
- Redis
- MongoDB
- Python
- Node.js

When an image isn't available locally, Docker automatically downloads it from Docker Hub.

---

## 4. Docker Image

A Docker Image is a **read-only blueprint** used to create containers.

An image contains:

- Application
- Runtime
- Libraries
- Dependencies
- Configuration

One image can create multiple containers.

---

## 5. Docker Container

A Docker Container is a running instance of a Docker Image.

You can:

- Start it
- Stop it
- Restart it
- Delete it

Containers are isolated from one another but share the host operating system kernel.

---

# Docker Architecture (In My Own Words)

The Docker workflow is simple:

1. The user enters a Docker command using the Docker Client.
2. The Docker Client sends the request to the Docker Daemon.
3. If the required image is not available locally, the Docker Daemon downloads it from Docker Hub.
4. The Docker Daemon creates a container from the image.
5. The container runs the application in an isolated environment.

Flow representation:

```
User
   │
   ▼
Docker Client (CLI)
   │
   ▼
Docker Daemon
   │
   ├────────► Docker Hub (Pull Image if needed)
   │
   ▼
Docker Image
   │
   ▼
Docker Container
```

---

# Task 2: Install Docker

## Verify Docker Installation

Check whether Docker is installed correctly.

```bash
docker --version
```

Example output:

```text
Docker version xx.xx.x, build xxxxxxx
```

---

## Verify Docker Daemon

```bash
docker info
```

This command displays Docker configuration, storage drivers, runtime information, and other system details.

---

## Run Your First Container

```bash
docker run hello-world
```

### What happens?

1. Docker searches for the `hello-world` image locally.
2. If not found, it downloads the image from Docker Hub.
3. Docker creates a new container.
4. The container runs the application.
5. It prints a success message.
6. The container exits because its task is complete.

This confirms that Docker is installed and working correctly.

---

# Task 3: Run Real Containers

## Run an Nginx Container

```bash
docker run -d -p 8080:80 --name nginx-demo nginx
```

### Explanation

- `docker run` → Creates and starts a container
- `-d` → Detached mode
- `-p 8080:80` → Maps port 8080 on the host to port 80 inside the container
- `--name nginx-demo` → Assigns a custom name
- `nginx` → Docker image

Now open:

```
http://localhost:8080
```

The default Nginx welcome page should appear.

---

## Run Ubuntu in Interactive Mode

```bash
docker run -it ubuntu
```

### Explanation

- `-i` → Interactive mode
- `-t` → Allocates a terminal
- `ubuntu` → Ubuntu image

You are now inside an Ubuntu container and can execute Linux commands such as:

```bash
pwd
ls
whoami
hostname
cat /etc/os-release
```

To exit:

```bash
exit
```

---

## List Running Containers

```bash
docker ps
```

Shows only currently running containers.

---

## List All Containers

```bash
docker ps -a
```

Displays:

- Running containers
- Exited containers
- Stopped containers

---

## Stop a Container

```bash
docker stop nginx-demo
```

Stops the running container gracefully.

---

## Remove a Container

```bash
docker rm nginx-demo
```

Removes the stopped container.

---

# Task 4: Explore Docker

## Run a Container in Detached Mode

```bash
docker run -d nginx
```

### What is Detached Mode?

Detached mode runs the container in the background.

Instead of attaching your terminal to the container, Docker immediately returns the container ID, allowing you to continue using your terminal while the container keeps running.

---

## Give a Container a Custom Name

```bash
docker run -d --name web-server nginx
```

Naming containers makes them easier to identify and manage instead of using randomly generated names.

---

## Port Mapping

```bash
docker run -d -p 8080:80 nginx
```

### Explanation

```
Host Port : Container Port
```

In this example:

```
localhost:8080
        │
        ▼
Container Port 80
```

This allows requests from your local machine to reach the application running inside the container.

---

## View Container Logs

```bash
docker logs nginx-demo
```

Displays the logs generated by the container, which are useful for debugging and monitoring application behavior.

---

## Execute a Command Inside a Running Container

```bash
docker exec -it nginx-demo bash
```

If Bash is unavailable:

```bash
docker exec -it nginx-demo sh
```

This opens a shell inside the running container, allowing you to inspect files, execute commands, and troubleshoot the application.

---

# Important Docker Commands Used

| Command | Purpose |
|----------|---------|
| `docker --version` | Check Docker version |
| `docker info` | Display Docker system information |
| `docker run` | Create and start a container |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker images` | List downloaded images |
| `docker stop` | Stop a container |
| `docker start` | Start a stopped container |
| `docker restart` | Restart a container |
| `docker rm` | Remove a container |
| `docker rmi` | Remove an image |
| `docker logs` | View container logs |
| `docker exec` | Execute a command inside a running container |

---

# Why Docker Matters for DevOps

Docker has become a fundamental technology in modern DevOps because it provides consistent, portable, and reproducible environments across development, testing, and production.

It enables teams to:

- Eliminate environment-related issues
- Package applications with dependencies
- Improve developer productivity
- Deploy applications consistently
- Scale microservices efficiently
- Integrate seamlessly with CI/CD pipelines
- Serve as the foundation for container orchestration platforms like Kubernetes

Today, Docker is widely used across cloud platforms and is an essential skill for DevOps engineers.

---

# Key Takeaways

- Docker is a containerization platform used to package applications and their dependencies.
- Containers are lightweight, portable, and share the host operating system kernel.
- Docker eliminates the "It works on my machine" problem by ensuring consistent environments.
- Docker architecture consists of the Docker Client, Docker Daemon, Docker Registry, Docker Images, and Docker Containers.
- Docker Hub is the default registry used to download container images.
- A Docker Image is a blueprint, while a Docker Container is a running instance of that image.
- Detached mode (`-d`) runs containers in the background.
- Interactive mode (`-it`) provides terminal access inside a container.
- Port mapping (`-p`) exposes container services to the host machine.
- Docker commands like `docker run`, `docker ps`, `docker stop`, `docker logs`, and `docker exec` are essential for managing containers.
- Docker forms the foundation of modern DevOps practices, CI/CD pipelines, microservices, and Kubernetes.

---

## Conclusion

Day 29 introduced the core concepts of Docker and containerization. I learned why containers are preferred over virtual machines, explored Docker's architecture, installed Docker, ran multiple containers, managed them using essential Docker commands, and understood how Docker simplifies application deployment. This foundational knowledge will be valuable as I continue learning Docker, Kubernetes, and modern DevOps workflows.
