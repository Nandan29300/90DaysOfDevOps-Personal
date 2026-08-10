# Day 31 - Dockerfile: Build Your Own Images

> **Goal:** Learn how to create your own Docker images using Dockerfiles, understand Dockerfile instructions, optimize image builds, and build a simple web application.

---

## Table of Contents

- [What is a Dockerfile?](#what-is-a-dockerfile)
- [Why Use Dockerfiles?](#why-use-dockerfiles)
- [Docker Build Workflow](#docker-build-workflow)
  
- [Task 1 - Your First Dockerfile](#task-1---your-first-dockerfile)
- [Task 2 - Understanding Dockerfile Instructions](#task-2---understanding-dockerfile-instructions)
- [Task 3 - CMD vs ENTRYPOINT](#task-3---cmd-vs-entrypoint)
- [Task 4 - Build a Simple Web App Image](#task-4---build-a-simple-web-app-image)
- [Task 5 - .dockerignore](#task-5---dockerignore)
- [Task 6 - Build Optimization and Cache](#task-6---build-optimization-and-cache)
---

# What is a Dockerfile?

A **Dockerfile** is a text file that contains a series of instructions used by Docker to automatically build a Docker image.

Instead of manually installing software, copying files, and configuring environments every time, we write those steps once inside a Dockerfile. Docker then follows those instructions exactly, making image creation automatic and repeatable.

Think of a Dockerfile as the **blueprint** for creating Docker images.

---

## Real-Life Analogy

```
Recipe
   │
   ▼
Dockerfile

Cake
   │
   ▼
Docker Image

Eating the Cake
   │
   ▼
Running Container
```

Just as a recipe tells a chef how to prepare a dish, a Dockerfile tells Docker how to build an image.

---

## Why Use Dockerfiles?

Without Dockerfiles:

- Install software manually
- Copy project files manually
- Configure the environment manually
- Easy to make mistakes
- Difficult to reproduce

With Dockerfiles:

- Automated image creation
- Reproducible builds
- Easy collaboration
- Version controlled
- Works the same everywhere
- Perfect for CI/CD pipelines

---

## Benefits of Dockerfiles

- Infrastructure as Code (IaC)
- Consistent environments
- Faster deployments
- Easy image versioning
- Easy sharing through Docker Hub
- Simple maintenance
- Supports build caching
- Reduces manual work

---

# Docker Build Workflow

Whenever you build a Docker image, Docker follows this workflow.

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

### Explanation

1. Write instructions inside a Dockerfile.
2. Run `docker build`.
3. Docker creates an image.
4. Run the image using `docker run`.
5. Docker creates and starts a container.

---

# Task 1 - Your First Dockerfile

## Objective

Create your first custom Docker image using Ubuntu as the base image.

---

## Folder Structure

```
my-first-image/
│
└── Dockerfile
```

---

## Dockerfile

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install curl -y

CMD echo "Hello from my custom image!"

```

---

---

## Build the Image

Navigate to the project folder.

```bash
cd my-first-image
```

Build the image.

```bash
docker build -t my-ubuntu:v1 .
```

---

## Command Breakdown

| Part | Description |
|------|-------------|
| `docker build` | Builds an image from a Dockerfile |
| `-t` | Assigns a name and tag |
| `my-ubuntu:v1` | Image name and version |
| `.` | Uses the current directory as the build context |

---

## Verify the Image

List all Docker images.

```bash
docker images
```

Example:

```text
REPOSITORY    TAG    IMAGE ID       CREATED
my-ubuntu     v1     xxxxxxxxxxxx   2 minutes ago
```

---

## Run the Container

```bash
docker run --rm my-ubuntu:v1
```

---

## Command Breakdown

| Part | Description |
|------|-------------|
| `docker run` | Creates and starts a container |
| `--rm` | Automatically removes the container after exit |
| `my-ubuntu:v1` | Image to execute |

---

## Expected Output

```text
Hello from my custom image!
```

---

---

# Task 2 - Understanding Dockerfile Instructions

## Objective

Learn the purpose of the most commonly used Dockerfile instructions and understand how they work together to create a Docker image.

---

## Folder Structure

```
sample-all-instructions/
│
├── Dockerfile
└── main.py
└── sample.txt (will be generated)
```

---

## Dockerfile

```Dockerfile
# Use official Python image as base image
FROM python:3.12-alpine

# Set the working directory
WORKDIR /app

# Copy application source code
COPY . .

RUN pip install -r requirements.txt

# Document the application's port
EXPOSE 5000

# Default command
CMD ["python", "app.py"]

```

---

## app.py

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from Docker!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## Build the Image

```bash
cd sample-all-instructions

docker build -t all-instructions:v1 .
```

---

## Run the Container

```bash
docker run --rm -p 5000:5000 all-instructions:v1
```

---

## Expected Output

```text
Hello from Docker! - when yo open http://ec2-public-ip:5000
```

---

---

# Task 3 - CMD vs ENTRYPOINT

This is one of the most commonly asked Docker interview topics.

Although they look similar,

they serve different purposes.

---

## CMD

CMD specifies the **default command** executed when a container starts.

Users can override it.

---

### Dockerfile

```Dockerfile
FROM alpine

CMD ["echo","hello"]
```

---

### Build

```bash
docker build -t cmdtest .
```

---

### Run

```bash
docker run --rm cmdtest
```

Output

```text
hello
```

---

### Override CMD

```bash
docker run --rm cmdtest echo world
```

Output

```text
world
```

Docker completely replaces the CMD instruction.

---

## ENTRYPOINT

ENTRYPOINT specifies the application's main executable.

Users cannot replace it accidentally.

Instead,

extra arguments are appended.

---

### Dockerfile

```Dockerfile
FROM alpine

ENTRYPOINT ["echo"]
```

---

### Build

```bash
docker build -t entrytest .
```

---

### Run

```bash
docker run --rm entrytest hello
```

Output

```text
hello
```

---

### Run Again

```bash
docker run --rm entrytest world foo
```

Output

```text
world foo
```

Docker automatically appends the arguments after ENTRYPOINT.

---

# CMD vs ENTRYPOINT

| Feature | CMD | ENTRYPOINT |
|----------|-----|------------|
| Purpose | Default command | Main executable |
| Can be overridden | Yes | No (without `--entrypoint`) |
| User flexibility | High | Low |
| Common use | Development | Production |
| Additional arguments | Replace CMD | Appended to ENTRYPOINT |

---

## Using CMD and ENTRYPOINT Together

They can work together.

Example

```Dockerfile
FROM python:3.11-slim

ENTRYPOINT ["python"]

CMD ["main.py"]
```

Running

```bash
docker run myimage
```

becomes

```bash
python main.py
```

Running

```bash
docker run myimage app.py
```

becomes

```bash
python app.py
```

ENTRYPOINT remains fixed,

while CMD provides default arguments.

---

# When Should You Use CMD?

Use CMD when:

- Users should be able to override the command.
- Building development containers.
- Creating flexible base images.
- Running scripts.

Examples

- Python
- Node.js
- Java
- Testing containers

---

# When Should You Use ENTRYPOINT?

Use ENTRYPOINT when:

- The application must always start.
- Building CLI tools.
- Creating wrapper scripts.
- Running production services.

Examples

- Nginx
- Redis
- MySQL
- PostgreSQL

---

## Interview Tip

A common interview question is:

**What is the difference between RUN, CMD and ENTRYPOINT?**

A simple answer is:

- **RUN** executes during image build.
- **CMD** provides the default command when the container starts.
- **ENTRYPOINT** defines the fixed executable that always runs.

---

## Key Points

- Every Dockerfile starts with a `FROM` instruction.
- `WORKDIR` avoids repeatedly using `cd`.
- `COPY` moves files from the host to the image.
- `RUN` executes commands while building the image.
- `EXPOSE` documents the application's port.
- `CMD` defines the default startup command.
- `ENTRYPOINT` defines the application's main executable.
- Docker executes Dockerfile instructions from top to bottom.
- Each instruction creates a cached image layer.

---

---

# Task 4 - Build a Simple Web App Image

## Objective

Let's build a simple static website and serve it using the official **Nginx Docker image**.

This demonstrates how Docker can package and run a web server with your own website.

---

## Folder Structure

```text
simple-website/
│
├── Dockerfile
└── index.html
└── .dockerignore

```

---

## index.html

```html
<!DOCTYPE html>
<html>
  <head><title>My Website</title></head>
  <body>
	  <h1>Welcome to my custom Dockerized website!</h1>
	  <h2> This is a simple static website served from a container. </h2>
  </body>

</html>

```

---

## Dockerfile

```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

---

## Build the Image

```bash
cd simple-website

docker build -t my-website:v1 .
```

---

## Run the Container

```bash
docker run --rm -p 80:80 my-website:v1
```

---

## Command Breakdown

| Command | Description |
|----------|-------------|
| `docker run` | Creates and starts a container |
| `--rm` | Removes the container after exit |
| `-p 80:80` | Maps port 80 on the host to port 80 inside the container |
| `my-website:v1` | Image name |

---

## Test the Website

Open your browser.

```
http://ec2-public-ip
```

You should see

```
Welcome to my custom Dockerized website!
This is a simple static website served from a container. 
```

---

# How Nginx Serves the Website

```
Browser
     │
     ▼
localhost:80
     │
     ▼
Host Port 80
     │
docker -p
     │
     ▼
Container Port 80
     │
     ▼
Nginx Server
     │
     ▼
index.html
```

---

## Why Use Nginx?

Nginx is

- Lightweight
- Fast
- Stable
- Production ready
- Excellent for serving static websites

That's why the official Docker image is widely used.

---

# Task 5 - .dockerignore

## What is .dockerignore?

A `.dockerignore` file tells Docker which files and folders should **not** be sent as part of the build context.

It works similarly to `.gitignore`.

---

## Example

```text
node_modules
.git
*.md
.env
```

---

## Why Use .dockerignore?

Without `.dockerignore`

```
docker build .

↓

Everything is sent

↓

Docker Daemon
```

Including

- README files
- Git history
- Environment files
- Logs
- node_modules

---

With `.dockerignore`

```
docker build .

↓

Only required files

↓

Docker Daemon
```

Result

- Faster builds
- Smaller build context
- Better security
- Smaller images

---

## Build the Image

```bash
docker build -t ignore-test:v1 .
```

---

## Verify

```bash
docker run --rm ignore-test:v1 find /usr/share/nginx/html/
```

If your project contained

- README.md
- .env
- .git
- node_modules

they should **not** appear inside the image.

---

## Best Practices

Always ignore

```text
.git
.env
node_modules
coverage
dist
build
*.log
*.md
.vscode
.idea
```

---

# Task 6 - Build Optimization and Cache

One of Docker's biggest advantages is **Layer Caching**.

---

## How Docker Builds Images

Docker executes every instruction one by one.

```
FROM
   │
   ▼
WORKDIR
   │
   ▼
COPY
   │
   ▼
RUN
   │
   ▼
CMD
```

Each instruction creates a **new image layer**.

---

## What is Docker Cache?

Suppose you build an image today.

Tomorrow you build the same Dockerfile again.

Docker notices that nothing changed.

Instead of rebuilding everything,

it reuses previously built layers.

This is called **Layer Cache**.

---

## Example

Dockerfile

```Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python","app.py"]
```

---

### First Build

```
FROM
Built

↓

WORKDIR
Built

↓

COPY requirements.txt
Built

↓

RUN pip install
Built

↓

COPY .
Built

↓

CMD
Built
```

Everything is created.

---

### Second Build

Only `app.py` changed.

Docker now performs

```
FROM
Cached

↓

WORKDIR
Cached

↓

COPY requirements.txt
Cached

↓

RUN pip install
Cached

↓

COPY .
Rebuilt

↓

CMD
Reused
```

Only the application code layer changes.

Everything else is reused.

Huge performance improvement.

---

# Poor Dockerfile

```Dockerfile
# Use official Python image as base image
FROM python:3.12-alpine

# Set the working directory
WORKDIR /app

# Copy application source code
COPY . .

RUN pip install -r requirements.txt

# Document the application's port
EXPOSE 5000

# Default command
CMD ["python", "app.py"]

```

Problem:
- Whenever **any file changes**
- Docker must reinstall every dependency.
- Very slow.

---

# Better Dockerfile

```Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python","app.py"]
```

Benefits
- Faster rebuilds
- Better caching
- Smaller CI build time
- Less network usage

---

# Why Layer Order Matters

Docker caches layers from top to bottom.

If an early layer changes,

every layer below it must be rebuilt.

```
Layer 1
Base Image

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

Changing

```
Application Code
```

only rebuilds Layer 4.

Changing

```
Layer 2
```

forces Layers 3 and 4 to rebuild.

---

# Docker Image Layering

Docker images are made of **read-only layers**.

```
┌─────────────────────────────┐
│ Application Code            │
├─────────────────────────────┤
│ Installed Dependencies      │
├─────────────────────────────┤
│ Python Runtime              │
├─────────────────────────────┤
│ Ubuntu / Alpine             │
└─────────────────────────────┘
```

When a container starts,

Docker adds one more layer.

```
Container
↓
Writable Layer
↓
Read-Only Image Layers
```

All file changes happen inside the writable layer.

The original image never changes.

---

# Dockerfile Best Practices

- Keep images small.
- Prefer Alpine or Slim images.
- Use `.dockerignore`.
- Combine related RUN commands.
- Avoid installing unnecessary packages.
- Copy dependency files before application code.
- Pin image versions instead of always using `latest`.
- Use one process per container whenever possible.
- Remove temporary files after installation.
- Keep Dockerfiles simple and readable.

---

# Common Mistakes

### Using `latest` Everywhere

Instead of

```Dockerfile
FROM python:latest
```

Prefer

```Dockerfile
FROM python:3.11-slim
```

Version pinning improves reproducibility.

---

### Forgetting `.dockerignore`

Large folders increase build time unnecessarily.

---

### Copying Everything First

Avoid

```Dockerfile
COPY . .

RUN pip install
```

This breaks Docker cache.

---

### Too Many RUN Instructions

Instead of

```Dockerfile
RUN apt update

RUN apt install curl

RUN apt install git
```

Combine them

```Dockerfile
RUN apt update && \
    apt install -y curl git
```

This reduces image layers.

---

# Useful Docker Commands

| Command | Description |
|----------|-------------|
| `docker build -t image:tag .` | Build image |
| `docker run image` | Run container |
| `docker run --rm image` | Auto remove container |
| `docker run -p 8080:80 image` | Publish ports |
| `docker images` | List images |
| `docker ps` | Running containers |
| `docker ps -a` | All containers |
| `docker rmi image` | Remove image |
| `docker build --no-cache .` | Ignore cache while building |

---

---

# Key Points

- Dockerfiles automate image creation.
- Every instruction creates a new image layer.
- Docker reuses cached layers whenever possible.
- `.dockerignore` keeps the build context clean.
- Layer order directly affects build performance.
- `CMD` is a default command.
- `ENTRYPOINT` defines the main executable.
- `EXPOSE` documents application ports.
- `COPY` copies files into the image.
- `RUN` installs software during image creation.

---

# Key Takeaways

- Dockerfiles are the blueprint for Docker images.
- Images are portable, reproducible, and version-controlled.
- Layer caching dramatically speeds up rebuilds.
- Organizing Dockerfile instructions correctly improves CI/CD performance.
- Always optimize image size using lightweight base images.
- Use `.dockerignore` to improve build speed and security.
- Understanding Dockerfile instructions is essential for production-ready containerization.

---
