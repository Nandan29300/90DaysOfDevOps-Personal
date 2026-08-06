# Day 31 - Dockerfile: Build Your Own Images

> **Goal:** Learn how to create your own Docker images using Dockerfiles, understand Dockerfile instructions, optimize image builds, and build a simple web application.

---

## Table of Contents

- [What is a Dockerfile?](#what-is-a-dockerfile)
- [Why Use Dockerfiles?](#why-use-dockerfiles)
- [Docker Build Workflow](#docker-build-workflow)
- [Task 1 - Your First Dockerfile](#task-1---your-first-dockerfile)
- [Understanding Build Context](#understanding-build-context)
- [Task 2 - Understanding Dockerfile Instructions](#task-2---understanding-dockerfile-instructions)

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

RUN apt-get update && apt-get install -y curl

CMD echo "Hello from my custom image!"
```

---

## Understanding Each Instruction

### 1. FROM

```Dockerfile
FROM ubuntu:latest
```

The `FROM` instruction specifies the **base image**.

Everything in your image starts from this image.

Docker first checks whether the image exists locally.

If not, Docker downloads it automatically.

Think of it as:

```
Your Image

        built on top of

Ubuntu Image
```

---

### 2. RUN

```Dockerfile
RUN apt-get update && apt-get install -y curl
```

The `RUN` instruction executes commands **while building the image**.

Here it performs two operations:

- Updates Ubuntu package lists.
- Installs the `curl` package.

Once the image is built, `curl` becomes a permanent part of the image.

**Note**

`RUN` executes only during image creation.

It does **not** execute every time a container starts.

---

### 3. CMD

```Dockerfile
CMD echo "Hello from my custom image!"
```

`CMD` defines the default command executed whenever a container starts.

Unlike `RUN`, this instruction executes **when the container runs**, not during image creation.

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

## What Happens During Build?

Docker performs these steps:

```
Step 1
Read Dockerfile

        │
        ▼

Step 2
Download Ubuntu Image
(if required)

        │
        ▼

Step 3
Run apt-get update

        │
        ▼

Step 4
Install curl

        │
        ▼

Step 5
Save Image

        │
        ▼

Finished
```

Every instruction creates a new **image layer**.

These layers are cached for faster future builds.

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

Congratulations! 🎉

You have successfully built and executed your first custom Docker image.

---

# Understanding Build Context

One of the most important Docker concepts is the **Build Context**.

Whenever you execute:

```bash
docker build .
```

Docker sends the current directory to the Docker daemon.

That directory is called the **Build Context**.

```
Project Folder
│
├── Dockerfile
├── app.py
├── requirements.txt
├── README.md
└── images/

        │

docker build .

        │

        ▼

Docker Daemon
```

Everything inside the build context can be accessed using instructions like:

```Dockerfile
COPY
```

or

```Dockerfile
ADD
```

---

## Why Does Build Context Matter?

If your project contains unnecessary files, Docker sends all of them during every build.

Large folders such as:

- node_modules
- .git
- videos
- logs
- screenshots

can make builds slower.

This is exactly why `.dockerignore` exists.

We'll learn about it later in this guide.

---

## Build Context Example

Suppose your project looks like this:

```
project/

├── Dockerfile
├── main.py
├── config.json
├── README.md
├── .env
├── .git/
└── node_modules/
```

Running:

```bash
docker build .
```

sends **everything** to Docker unless ignored.

Later, using a `.dockerignore` file, Docker will skip unnecessary files before sending the build context.

This results in:

- Faster builds
- Smaller build context
- Better security
- Reduced network transfer
- Improved CI/CD performance

---

## Key Points

- A Dockerfile is a blueprint for building Docker images.
- Docker executes Dockerfile instructions from top to bottom.
- `FROM` specifies the base image.
- `RUN` executes commands during image creation.
- `CMD` defines the default command when a container starts.
- Every Dockerfile instruction creates a new image layer.
- Docker caches layers to speed up future builds.
- The current directory becomes the build context when running `docker build .`.
- Build context includes every file unless excluded using `.dockerignore`.

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
```

---

## Dockerfile

```Dockerfile
# Use official Python image as base image
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy application source code
COPY main.py .

# Install dependencies if required
# RUN pip install flask

# Document the application's port
EXPOSE 5000

# Default command
CMD ["python", "main.py"]
```

---

## main.py

```python
print("Hello from a Dockerfile using all instructions!")
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
docker run --rm all-instructions:v1
```

---

## Expected Output

```text
Hello from a Dockerfile using all instructions!
```

---

# Understanding Dockerfile Instructions

Docker reads every instruction from **top to bottom**.

Each instruction creates a **new image layer**.

```
Dockerfile
     │
     ▼
Instruction 1
     │
Instruction 2
     │
Instruction 3
     │
Instruction 4
     │
Finished Image
```

---

## 1. FROM

### Syntax

```Dockerfile
FROM image:tag
```

Example

```Dockerfile
FROM python:3.11-slim
```

### Purpose

The `FROM` instruction specifies the **base image**.

Every Dockerfile **must begin with a FROM instruction** (except advanced multi-stage builds).

Docker builds everything on top of this image.

```
Your Image
      ▲
      │
Python Image
      ▲
      │
Linux OS
```

### Common Examples

```Dockerfile
FROM ubuntu:latest
```

```Dockerfile
FROM nginx:alpine
```

```Dockerfile
FROM node:22
```

```Dockerfile
FROM python:3.11-slim
```

### Best Practice

Prefer smaller images whenever possible.

Good

```Dockerfile
FROM python:3.11-slim
```

Better

```Dockerfile
FROM alpine
```

Smaller images mean:

- Faster downloads
- Smaller storage usage
- Better security
- Faster deployments

---

## 2. WORKDIR

### Syntax

```Dockerfile
WORKDIR /app
```

### Purpose

Sets the default working directory inside the container.

Without WORKDIR

```Dockerfile
COPY main.py /app/main.py

RUN cd /app && python main.py
```

With WORKDIR

```Dockerfile
WORKDIR /app

COPY main.py .

CMD ["python","main.py"]
```

Everything automatically executes inside `/app`.

---

### Example

```
Container

/

├── bin
├── usr
├── etc
└── app
      │
      ├── main.py
      └── requirements.txt
```

Docker automatically starts from `/app`.

---

## 3. COPY

### Syntax

```Dockerfile
COPY <source> <destination>
```

Example

```Dockerfile
COPY main.py .
```

or

```Dockerfile
COPY . .
```

---

### Purpose

Copies files from your local machine into the Docker image.

```
Local Machine

main.py

        │

COPY

        ▼

Docker Image

/app/main.py
```

---

### Common Examples

Copy one file

```Dockerfile
COPY app.py .
```

Copy multiple files

```Dockerfile
COPY requirements.txt .
```

Copy entire project

```Dockerfile
COPY . .
```

---

### Important Note

`COPY . .`

means

```
Current Folder

↓

Current Working Directory
```

This is one of the most frequently used Dockerfile instructions.

---

## 4. RUN

### Syntax

```Dockerfile
RUN command
```

Example

```Dockerfile
RUN apt-get update
```

or

```Dockerfile
RUN pip install flask
```

---

### Purpose

Executes commands while building the image.

These commands execute **only once during build**.

Example

```Dockerfile
RUN mkdir logs
```

The `logs` folder becomes part of the final image.

---

### Common Uses

Installing packages

```Dockerfile
RUN apt-get install curl
```

Installing Python libraries

```Dockerfile
RUN pip install flask
```

Creating directories

```Dockerfile
RUN mkdir uploads
```

Changing permissions

```Dockerfile
RUN chmod +x script.sh
```

---

### RUN vs CMD

| RUN | CMD |
|------|------|
| Runs during image build | Runs when container starts |
| Creates image layers | Does not create build layers |
| Used for installation | Used to start applications |

---

## 5. EXPOSE

### Syntax

```Dockerfile
EXPOSE 5000
```

---

### Purpose

Documents which port the application uses.

It **does not actually publish the port**.

Think of it as documentation for anyone using the image.

---

### Important

This

```Dockerfile
EXPOSE 5000
```

does NOT make the application available.

You still need

```bash
docker run -p 5000:5000 image-name
```

---

### Flow

```
Application

↓

Port 5000

↓

EXPOSE 5000

↓

docker run -p 5000:5000
```

---

## 6. CMD

### Syntax

```Dockerfile
CMD ["python","main.py"]
```

---

### Purpose

Defines the default command executed when the container starts.

Only one CMD should exist.

If multiple CMD instructions exist,

Docker only uses the **last one**.

---

### Examples

```Dockerfile
CMD ["python","main.py"]
```

```Dockerfile
CMD ["npm","start"]
```

```Dockerfile
CMD ["nginx","-g","daemon off;"]
```

---

# Dockerfile Execution Order

Docker processes instructions from top to bottom.

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

Every instruction creates a new cached layer except metadata-only instructions where applicable.

---

# Image Layers

Imagine the image like this:

```
┌───────────────────────────┐
│ CMD                       │
├───────────────────────────┤
│ EXPOSE                    │
├───────────────────────────┤
│ RUN                       │
├───────────────────────────┤
│ COPY                      │
├───────────────────────────┤
│ WORKDIR                   │
├───────────────────────────┤
│ Base Image                │
└───────────────────────────┘
```

When Docker rebuilds,

it checks each layer one by one.

If nothing changed,

Docker reuses the cached layer.

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
```

---

## index.html

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

## Dockerfile

```Dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html
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
docker run --rm -p 8080:80 my-website:v1
```

---

## Command Breakdown

| Command | Description |
|----------|-------------|
| `docker run` | Creates and starts a container |
| `--rm` | Removes the container after exit |
| `-p 8080:80` | Maps port 8080 on the host to port 80 inside the container |
| `my-website:v1` | Image name |

---

## Test the Website

Open your browser.

```
http://localhost:8080
```

You should see

```
Welcome to my custom Dockerized website!
```

---

# How Nginx Serves the Website

```
Browser
     │
     ▼
localhost:8080
     │
     ▼
Host Port 8080
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

# Task 6 - Build Optimization & Cache

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

CMD ["python","main.py"]
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

Only `main.py` changed.

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
COPY . .

RUN pip install -r requirements.txt
```

Problem

Whenever **any file changes**

Docker must reinstall every dependency.

Very slow.

---

# Better Dockerfile

```Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python","main.py"]
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

# Interview Questions

### What is a Dockerfile?

A text file containing instructions used to build Docker images.

---

### Difference between RUN and CMD?

- RUN executes during image build.
- CMD executes when the container starts.

---

### Difference between CMD and ENTRYPOINT?

- CMD provides a default command.
- ENTRYPOINT specifies the main executable.

---

### What is Build Context?

The directory sent to Docker during `docker build`.

---

### Why use `.dockerignore`?

To exclude unnecessary files from the build context.

---

### Why is Docker cache important?

It speeds up image builds by reusing unchanged layers.

---

### Why should dependency installation come before copying source code?

Because dependencies change less frequently, Docker can cache that layer and avoid reinstalling packages on every build.

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
