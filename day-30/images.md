# Day 30 – Docker Images & Container Lifecycle


> **Topic:** Docker Images & Container Lifecycle  
> **Goal:** Understand how Docker images are built, how containers work, image layers, caching, and the complete lifecycle of a container.

---

#  What is a Docker Image?

A **Docker Image** is a **read-only blueprint** used to create Docker containers.

It contains everything required to run an application:

- Application code
- Runtime
- Libraries
- Dependencies
- Environment variables
- Default commands

Think of it like:

- 📷 **Image = Photo**
- 🚀 **Container = Running Person in the Photo**

One image can create multiple containers.

Example:

```
nginx image
      │
      ├── Container 1
      ├── Container 2
      └── Container 3
```

---

#  What is a Docker Container?

A **Docker Container** is a **running instance of an image**.

Unlike an image:

- It has its own filesystem changes
- It has its own process
- It can be started, stopped, paused, restarted, or removed

Containers are lightweight because they share the host OS kernel.

---

# Task 1 – Docker Images

## 1. Pull Docker Images

Pull the required images from Docker Hub.

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine
```

Example Output

```
Using default tag: latest
latest: Pulling from library/nginx
Digest: sha256:...
Status: Downloaded newer image for nginx:latest
```

---

## 2. List All Images

```bash
docker images
```

Example Output

| Repository | Tag | Image ID | Size |
|------------|-----|----------|------|
| nginx | latest | xxxxx | ~190MB |
| ubuntu | latest | xxxxx | ~80MB |
| alpine | latest | xxxxx | ~8MB |

---

## 3. Ubuntu vs Alpine

### Ubuntu

- Full Linux distribution
- Includes many utilities
- Larger image size
- Easier for development

Approximate Size:

```
80MB+
```

---

### Alpine

- Minimal Linux distribution
- Extremely lightweight
- Smaller attack surface
- Faster downloads
- Ideal for production containers

Approximate Size:

```
8MB
```

---

### Why is Alpine Smaller?

Alpine uses the musl C library and BusyBox utilities, while Ubuntu uses the glibc C library and GNU utilities, making Ubuntu larger but more compatible with many applications.

Because Alpine contains only the essential components required to run Linux applications.

It removes unnecessary packages, documentation, and utilities, making the image much smaller than Ubuntu.

---

## 4. Inspect an Image

```bash
docker image inspect nginx
```

Useful information available:

- Image ID
- Architecture
- Operating System
- Environment Variables
- Entrypoint
- Default Command
- Labels
- Layers
- Creation Date

---

## 5. Remove an Image

```bash
docker image rm ubuntu
```

If the image is used by a container:

```
Error:
image is being used by stopped container
```

Remove the container first or force remove:

```bash
docker image rm -f ubuntu
```

---

# Task 2 – Docker Image Layers

Run:

```bash
docker image history nginx
```

Example

```
IMAGE          CREATED      CREATED BY             SIZE
xxxxx          2 days ago   CMD ["nginx"]          0B
xxxxx          2 days ago   EXPOSE 80              0B
xxxxx          2 days ago   COPY ...               4KB
xxxxx          2 days ago   RUN apt update         35MB
xxxxx          2 days ago   Base Layer             120MB
```

---

## What are Image Layers?

A Docker image is made up of **multiple read-only layers**.

Every Dockerfile instruction creates a new layer.

Example:

```
FROM ubuntu
RUN apt update
RUN apt install nginx
COPY . .
CMD ["nginx"]
```

Each instruction becomes one layer.

```
Base Layer
     │
RUN apt update
     │
RUN install nginx
     │
COPY files
     │
CMD
```

---

## Why Docker Uses Layers

Docker layers provide several advantages:

- Faster image builds
- Efficient storage
- Layer reuse
- Better caching
- Faster downloads

For example, if only the application code changes, Docker reuses the previous layers and rebuilds only the changed layer.

---

## Why Do Some Layers Show 0B?

Instructions like:

- CMD
- EXPOSE
- ENV
- LABEL

change only image metadata.

They don't add files to the filesystem, so Docker reports their size as **0B**.

---

# Task 3 – Container Lifecycle

Docker containers move through different states during their lifecycle.

---

## Step 1 – Create a Container (Without Starting)

```bash
docker create --name demo-container nginx
```

Check status:

```bash
docker ps -a
```

State:

```
Created
```

---

## Step 2 – Start the Container

```bash
docker start demo-container
```

Check:

```bash
docker ps -a
```

State:

```
Up
```

---

## Step 3 – Pause the Container

```bash
docker pause demo-container
```

Check:

```bash
docker ps -a
```

State:

```
Paused
```

---

## Step 4 – Unpause

```bash
docker unpause demo-container
```

State:

```
Running
```

---

## Step 5 – Stop

```bash
docker stop demo-container
```

State:

```
Exited
```

---

## Step 6 – Restart

```bash
docker restart demo-container
```

State:

```
Running
```

---

## Step 7 – Kill

```bash
docker kill demo-container
```

State:

```
Exited
```

Difference:

- `docker stop` sends **SIGTERM** and allows the application to shut down gracefully.
- `docker kill` sends **SIGKILL**, stopping the container immediately.

---

## Step 8 – Remove

```bash
docker rm demo-container
```

Verify:

```bash
docker ps -a
```

Container is removed.

---

## Container Lifecycle Flow

```
Create
   │
   ▼
Created
   │
Start
   ▼
Running
   │
Pause
   ▼
Paused
   │
Unpause
   ▼
Running
   │
Stop
   ▼
Exited
   │
Restart
   ▼
Running
   │
Kill
   ▼
Exited
   │
Remove
   ▼
Deleted
```

---

# Task 4 – Working with Running Containers

## Run Nginx in Detached Mode

```bash
docker run -d --name my-nginx -p 8080:80 nginx
```

Explanation:

- `-d` → Detached mode
- `--name` → Container name
- `-p` → Port mapping
- `nginx` → Image name

---

## View Logs

```bash
docker logs my-nginx
```

Displays the container logs.

---

## View Real-Time Logs

```bash
docker logs -f my-nginx
```

`-f` means **follow**, showing logs as they are generated.

Exit using:

```
Ctrl + C
```

---

## Enter the Container

```bash
docker exec -it my-nginx /bin/bash
```

If Bash is unavailable (common in Alpine-based images):

```bash
docker exec -it my-nginx sh
```

Explore the filesystem:

```bash
pwd
ls
cd /
ls
```

Exit:

```bash
exit
```

---

## Run a Single Command

```bash
docker exec my-nginx ls /
```

This executes only the `ls /` command without opening an interactive shell.

---

## Inspect the Container

```bash
docker inspect my-nginx
```

Useful information includes:

- Container ID
- Image used
- Current State
- IP Address
- Port Mappings
- Mounts
- Networks
- Environment Variables
- Restart Policy

---

# Task 5 – Cleanup

## Stop All Running Containers

```bash
docker stop $(docker ps -q)
```

---

## Remove All Stopped Containers

```bash
docker container prune
```

Or without confirmation:

```bash
docker container prune -f
```

---

## Remove Unused Images

```bash
docker image prune
```

Remove all unused images:

```bash
docker image prune -a
```

---

## Check Docker Disk Usage

```bash
docker system df
```

Example Output

```
TYPE            TOTAL     ACTIVE     SIZE
Images          5         2          800MB
Containers      3         1          20MB
Volumes         1         1          15MB
Build Cache     0         0          0B
```

---

## Remove Unused Docker Resources

```bash
docker system prune
```

Remove everything unused:

```bash
docker system prune -a
```

---

#  How Docker Images and Containers Work Internally

A Docker **Image** is **read-only**. Once an image is built, its layers cannot be modified.

When you create a container from an image, Docker **does not modify the original image**. Instead, it adds a **thin writable layer** on top of the read-only image layers.

```
             Container
      +----------------------+
      | Thin Writable Layer  |  ← Changes are stored here
      +----------------------+
      | Read-only Layer 3    |
      +----------------------+
      | Read-only Layer 2    |
      +----------------------+
      | Read-only Layer 1    |
      +----------------------+
      | Base Image Layer     |
      +----------------------+
```

Any changes made inside the container (creating files, editing files, deleting files, installing packages, etc.) are stored only in the **thin writable layer**.

The original image remains unchanged.

If the container is removed, everything stored in its writable layer is also removed unless the data is stored in a Docker Volume or Bind Mount.

---

#  What is Union File System (UnionFS)?

Docker uses a **Union File System (UnionFS)** to combine multiple read-only image layers and a single writable container layer into one unified filesystem.

Instead of copying all image files every time a container starts, UnionFS simply stacks the layers together, making them appear as one complete filesystem.

Benefits of UnionFS:

- Efficient storage through shared layers
- Faster container startup
- Faster image downloads
- Layer reuse across multiple images
- Better build caching

In simple terms:

> **UnionFS allows Docker to merge multiple image layers and one writable container layer into a single filesystem that the container can use.**

```
Application
      │
      ▼
+-----------------------+
| Writable Layer        |
+-----------------------+
| Read-only Layer 3     |
+-----------------------+
| Read-only Layer 2     |
+-----------------------+
| Read-only Layer 1     |
+-----------------------+
        │
        ▼
   Union File System
        │
        ▼
 Appears as One Filesystem
```

---

> **Note:** Docker uses **Copy-on-Write (CoW)**. When a file from a read-only image layer needs to be modified, Docker first copies it into the container's writable layer and then applies the changes there. This keeps the original image immutable while allowing containers to modify files independently.

---

# 💡 Key Takeaways

- A Docker **Image** is a read-only template used to create containers.
- A **Container** is a running instance of an image.
- One image can create multiple containers.
- Docker images consist of multiple **read-only layers**.
- Layers improve build speed through caching and reuse.
- Metadata instructions like `CMD` and `EXPOSE` create **0B** layers.
- Container lifecycle includes **Create → Start → Pause → Unpause → Stop → Restart → Kill → Remove**.
- `docker logs` helps monitor container output.
- `docker exec` allows running commands inside a container.
- `docker inspect` provides detailed configuration and runtime information.
- Docker cleanup commands help reclaim unused disk space.

---

Today I learned how Docker images are structured, how containers transition through different lifecycle states, how image layers improve efficiency with caching, and how to inspect, manage, and clean up Docker resources effectively.
