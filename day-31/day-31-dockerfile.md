# Day 31 - Dockerfile: Build Your Own Images

> **Goal:** Learn how to create your own Docker images using Dockerfiles, understand Dockerfile instructions, optimize image builds, and build a simple web application.

---

# What is a Dockerfile?

A **Dockerfile** is a text file that contains instructions for Docker to automatically build an image.

Instead of manually installing packages and configuring everything every time, we simply write the steps once inside a Dockerfile.

Think of it as:

```
Recipe → Dockerfile
Cake → Docker Image
Eating the Cake → Running Container
```

Benefits:

- Reproducible builds
- Version controlled
- Easy deployment
- Same environment everywhere
- Automation friendly

---

## Docker Build Flow

```
Dockerfile
     │
     ▼
docker build
     │
     ▼
 Docker Image
     │
docker run
     │
     ▼
 Running Container
```

---

## Task 1 - Your First Dockerfile

### Folder Structure

```
my-first-image/
│
└── Dockerfile
```

---

### Dockerfile

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

CMD echo "Hello from my custom image!"
```

---

### Explanation

#### FROM

Selects the base image.

```
FROM ubuntu:latest
```

Docker downloads Ubuntu (if not already available) and starts building from it.

---

#### RUN

Executes commands while building the image.

```
RUN apt-get update && apt-get install -y curl
```

This installs curl permanently into the image.

---

#### CMD

Default command executed when the container starts.

```
CMD echo "Hello from my custom image!"
```

---

### Build Image

```bash
cd my-first-image

docker build -t my-ubuntu:v1 .
```

Explanation

```
docker build
```

Creates an image.

```
-t
```

Assigns a tag.

```
my-ubuntu:v1
```

Image name and version.

```
.
```

Current directory as build context.

---

### Run Container

```bash
docker run --rm my-ubuntu:v1
```

Output

```
Hello from my custom image!
```

---

## Understanding Build Context

When running

```bash
docker build .
```

Docker sends the **current directory** to the Docker daemon.

That directory is called the **Build Context**.

```
Project Folder
      │
      ▼
Docker Build Context
      │
      ▼
Docker Daemon
```

Everything inside the build context can be copied into the image.

---

## Task 2 - Dockerfile Instructions

Folder

```
sample-all-instructions/
│
├── Dockerfile
└── main.py
```

---

### Dockerfile

```Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY main.py .

EXPOSE 5000

CMD ["python", "main.py"]
```

---

### main.py

```python
print("Hello from a Dockerfile using all instructions!")
```

---

### Build

```bash
docker build -t all-instructions:v1 .
```

---

### Run

```bash
docker run --rm all-instructions:v1
```

Output

```
Hello from a Dockerfile using all instructions!
```

---

## Dockerfile Instructions Explained

### FROM

Specifies the base image.

Example

```Dockerfile
FROM python:3.11-slim
```

Everything begins from this image.

---

### WORKDIR

Sets the working directory inside the container.

```Dockerfile
WORKDIR /app
```

Instead of repeatedly writing

```bash
cd /app
```

Docker automatically executes future instructions from this directory.

---

### COPY

Copies files from the host machine into the image.

```Dockerfile
COPY main.py .
```

Equivalent to

```
Host
main.py
↓
Container
/app/main.py
```

---

### RUN

Executes commands while building the image.

Example

```Dockerfile
RUN pip install flask
```

Runs only during image creation.

---

### EXPOSE

Documents which port the application uses.

```Dockerfile
EXPOSE 5000
```

Important:

It **does NOT** publish the port.

Port publishing happens with

```bash
docker run -p
```

---

### CMD

Specifies the default command executed when the container starts.

Example

```Dockerfile
CMD ["python","main.py"]
```

---

## Dockerfile Lifecycle

```
FROM
↓
WORKDIR
↓
COPY
↓
RUN
↓
EXPOSE
↓
CMD
```

---

## Task 3 - CMD vs ENTRYPOINT

Understanding this difference is very important.

---

### CMD Example

Dockerfile

```Dockerfile
FROM alpine

CMD ["echo","hello"]
```

Build

```bash
docker build -t cmdtest .
```

Run

```bash
docker run --rm cmdtest
```

Output

```
hello
```

Override CMD

```bash
docker run --rm cmdtest echo world
```

Output

```
world
```

Docker completely replaces CMD.

---

### ENTRYPOINT Example

Dockerfile

```Dockerfile
FROM alpine

ENTRYPOINT ["echo"]
```

Build

```bash
docker build -t entrytest .
```

Run

```bash
docker run --rm entrytest hello
```

Output

```
hello
```

Run

```bash
docker run --rm entrytest world foo
```

Output

```
world foo
```

ENTRYPOINT always executes.

Additional arguments are appended.

---

## CMD vs ENTRYPOINT

| CMD | ENTRYPOINT |
|------|------------|
| Default command | Fixed executable |
| Can be overridden | Cannot be replaced easily |
| Flexible | Consistent |
| Best for default behavior | Best for main application |

---

## When Should You Use Them?

Use CMD

- Python scripts
- Development containers
- Base images
- Flexible execution

Use ENTRYPOINT

- Production applications
- Wrapper scripts
- Utility containers
- CLI tools

---

## Task 4 - Build a Simple Website

Folder

```
simple-website/
│
├── Dockerfile
└── index.html
```

---

### index.html

```html
<!DOCTYPE html>
<html>
<head>
<title>My Website</title>
</head>

<body>
<h1>Welcome to my custom Dockerized website!</h1>
</body>
</html>
```

---

### Dockerfile

```Dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html
```

---

### Build

```bash
docker build -t my-website:v1 .
```

---

### Run

```bash
docker run --rm -p 8080:80 my-website:v1
```

Visit

```
http://localhost:8080
```

You should see your custom webpage.

---

## How Nginx Serves the Website

```
Browser
↓
localhost:8080
↓
Docker Port Mapping
↓
Container Port 80
↓
Nginx
↓
index.html
```

---

## Task 5 - .dockerignore

Similar to `.gitignore`, Docker also supports ignoring files.

---

### .dockerignore

```text
node_modules
.git
*.md
.env
```

These files are excluded from the build context.

---

## Why Use .dockerignore?

Benefits

- Faster builds
- Smaller images
- Better security
- Cleaner Docker context

Never include

- Git history
- Secrets
- Environment files
- Large dependency folders

---

## Build

```bash
docker build -t ignore-test:v1 .
```

---

## Verify

```bash
docker run --rm ignore-test:v1 find /usr/share/nginx/html/
```

README.md, .git, .env and node_modules should not appear if they exist in your project.

---

## Task 6 - Build Optimization and Cache

Docker builds images layer by layer.

Each instruction creates a layer.

```
FROM
↓
WORKDIR
↓
COPY
↓
RUN
↓
CMD
```

Each layer is cached.

---

### Poor Dockerfile

```Dockerfile
COPY . .

RUN pip install -r requirements.txt
```

Every source code change forces dependencies to reinstall.

---

### Better Dockerfile

```Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python","main.py"]
```

Now Docker reuses cached dependency layers.

Only the application code layer rebuilds.

Result:

- Faster builds
- Less network usage
- Better CI/CD performance

---

## Why Layer Order Matters

Imagine these layers:

```
Layer 1
Ubuntu
↓
Layer 2
Python
↓
Layer 3
Dependencies
↓
Layer 4
Application Code
```

If only the application changes,

Docker rebuilds only Layer 4.

The first three layers come from cache.

Huge time savings.

---

## Docker Image Layering

```
Application Code

────────────

Python Packages

────────────

Operating System

────────────

Base Image
```

Every layer is read-only.

When a container starts, Docker adds a thin writable layer on top.

```
Container
↓
Writable Layer
↓
Image Layers (Read Only)
```

---

## Useful Commands Cheat Sheet

| Command | Description |
|----------|-------------|
| docker build -t name:tag . | Build image |
| docker run image | Run container |
| docker run --rm image | Remove container after exit |
| docker run -p 8080:80 image | Publish ports |
| docker images | List images |
| docker ps | Running containers |
| docker ps -a | All containers |
| docker rmi image | Remove image |
| docker build --no-cache . | Build without cache |

---

## Key Points

- Dockerfiles automate image creation.
- Every Dockerfile instruction creates a new image layer.
- Layer caching dramatically speeds up rebuilds.
- Always start with lightweight base images whenever possible.
- Use `.dockerignore` to reduce build context.
- `CMD` provides the default command.
- `ENTRYPOINT` defines the main executable.
- `EXPOSE` only documents the intended port.
- `COPY` moves files into the image.
- `RUN` executes commands during image creation.

---

## Key Takeaways

- Dockerfiles are the blueprint for Docker images.
- Images become portable and reproducible across systems.
- Layer ordering directly impacts build performance.
- Use Docker cache effectively by copying dependencies before source code.
- Use `.dockerignore` to keep unnecessary files out of the image.
- Prefer slim or Alpine base images to reduce image size.
- Learn the difference between `CMD` and `ENTRYPOINT` because it is frequently asked in interviews.
- Mastering Dockerfiles is the first step toward building production-ready containers and efficient CI/CD pipelines.

---

## Today's Learning Summary

Today I learned:

- Creating Dockerfiles
- Building custom Docker images
- Core Dockerfile instructions
- CMD vs ENTRYPOINT
- Serving websites using Nginx
- Using .dockerignore
- Docker build cache
- Layer optimization
- Best practices for writing production-ready Dockerfiles
