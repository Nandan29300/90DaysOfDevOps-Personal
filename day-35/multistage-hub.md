# Day 35 – Multi-Stage Builds & Docker Hub

## Task 1: The Problem with Large Images

### Objective

Understand why single-stage Docker images are often large and inefficient.

---

### Application

Created a simple Go application.

#### main.go

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello from Go inside Docker!")
}
```

---

### Single-Stage Dockerfile

```dockerfile
FROM golang:1.25

WORKDIR /app

COPY main.go .

RUN go build -o hello main.go

CMD ["./hello"]
```

---

### Build Image

```bash
docker build -t go-single-stage:v1 .
```

---

### Run Container

```bash
docker run --rm go-single-stage:v1
```

Output:

```text
Hello from Go inside Docker!
```

---

### Check Image Size

```bash
docker images
```

Output:

```text
REPOSITORY        TAG       SIZE
go-single-stage   v1        1.22GB
```

Image Size: `1.22GB`

---

### Observation

The image size is large because the final image contains:

- Go compiler
- Build dependencies
- Source code
- Compiled binary
- Build tools and package managers

Everything required for building remains inside the image even though only the final binary is needed to run the application.

This increases:

- Storage usage
- Image pull time
- Security attack surface

Multi-stage builds solve this problem by separating the build environment from the runtime environment.

---

# Task 2: Multi-Stage Build

## Objective

Rewrite the single-stage Dockerfile using a multi-stage build so that the final image contains only the required runtime components and the compiled Go application.

---

## Multi-Stage Dockerfile

### Dockerfile.multistage

```dockerfile
# Stage 1: Build
FROM golang:1.24-alpine AS builder

WORKDIR /build

# Copy Go source code
COPY main.go .

# Build a statically linked Go binary
RUN CGO_ENABLED=0 GOOS=linux go build -o hello main.go


# Stage 2: Runtime
FROM alpine:3.22

WORKDIR /app

# Copy only the compiled binary from the builder stage
COPY --from=builder /build/hello .

# Run as non-root user
USER nobody

CMD ["./hello"]
```

---

## Stage 1 - Builder

```dockerfile
FROM golang:1.24-alpine AS builder
```

The first stage contains the Go compiler and required build tools.

The application source code is copied into the builder:

```dockerfile
COPY main.go .
```

Then the Go application is compiled:

```dockerfile
RUN CGO_ENABLED=0 GOOS=linux go build -o hello main.go
```

The output is a compiled binary named:

```text
hello
```

---

## Stage 2 - Runtime

```dockerfile
FROM alpine:3.22
```

The second stage uses a much smaller runtime image.

Only the compiled application is copied from the builder:

```dockerfile
COPY --from=builder /build/hello .
```

The Go compiler, SDK, source code and other build dependencies are not included in the final image.

---

## Build Command

```bash
docker build -f Dockerfile.multistage -t go-multi-stage:v1 .
```

---

## Run Container

```bash
docker run --rm go-multi-stage:v1
```

### Output

```text
Hello from Day 35 - Go Docker!
```

---

## Image Size Comparison

Command used:

```bash
docker images
```

| Image | Tag | Size |
|---|---|---:|
| go-single-stage | v1 | **1.22 GB** |
| go-multi-stage | v1 | **16.3 MB** |

### Size Reduction

```text
1.22 GB - 16.3 MB = 1.204 GB
```

The multi-stage image is approximately **98.7% smaller** than the single-stage image.

---

## Why Is the Multi-Stage Image Smaller?

In the single-stage build, the final image contains the complete Go development environment, including:

- Go compiler
- Go SDK
- Build tools
- Source code
- Compiled application

The compiler and development tools are required only during the build process. They are not required to run the application.

With a multi-stage build:

```text
Stage 1: Builder
Go SDK + Compiler + Source Code
              │
              ▼
        Compiled Binary
              │
              ▼
Stage 2: Runtime
Minimal Alpine Image + Binary
```

The `COPY --from=builder` instruction copies only the compiled application into the final image.

Therefore, unnecessary build dependencies are left behind in the builder stage.

### Key Benefit

Multi-stage builds produce:

- Smaller images
- Faster image transfers
- Faster deployments
- Reduced attack surface
- Cleaner production images

---

## Key Concept

```dockerfile
FROM golang:1.24-alpine AS builder
```

creates a named build stage.

Then:

```dockerfile
COPY --from=builder /build/hello .
```

copies the required artifact from that stage into the final runtime image.

> **Build with a full environment, run with only what you need.**

---

# Task 3: Push to Docker Hub

## Objective

Push the optimized multi-stage Go Docker image to Docker Hub and verify that it can be pulled and executed successfully.

---

## Docker Hub Repository

Repository:

```text
YOUR_USERNAME/go-multi-stage
```

Image tag:

```text
v1
```

> Replace `YOUR_USERNAME` with the actual Docker Hub username.

---

## Login to Docker Hub

```bash
docker login
```

Successful login:

```text
Login Succeeded
```

---

## Tag the Image

The local multi-stage image:

```text
go-multi-stage:v1
```

was tagged for Docker Hub:

```bash
docker tag go-multi-stage:v1 YOUR_USERNAME/go-multi-stage:v1
```

Docker Hub image format:

```text
YOUR_USERNAME/go-multi-stage:v1
```

---

## Push Image

```bash
docker push YOUR_USERNAME/go-multi-stage:v1
```

The image was successfully uploaded to Docker Hub.

---

## Verify on Docker Hub

The repository was checked on Docker Hub.

Repository:

```text
YOUR_USERNAME/go-multi-stage
```

Available tag:

```text
v1
```

---

## Pull Image

To verify that the image can be downloaded from Docker Hub:

```bash
docker pull YOUR_USERNAME/go-multi-stage:v1
```

---

## Run Pulled Image

```bash
docker run --rm YOUR_USERNAME/go-multi-stage:v1
```

Output:

```text
Hello from Day 35 - Go Docker!
```

---

## Verification

The image was successfully:

1. Built using a multi-stage Dockerfile
2. Tagged with the Docker Hub repository name
3. Pushed to Docker Hub
4. Removed from the local environment
5. Pulled again from Docker Hub
6. Successfully executed

This confirms that the Docker image is available for distribution through Docker Hub.

---

# Task 4: Docker Hub Repository

## Objective

Explore the Docker Hub repository, add a repository description, understand image tags, and compare pulling a specific tag with pulling the `latest` tag.

---

## Docker Hub Repository

Repository:

```text
YOUR_USERNAME/go-multi-stage
```

The repository contains the Go Docker image pushed during Task 3.

---

## Repository Description

Added the following description to the Docker Hub repository:

> A Dockerized Go application demonstrating multi-stage builds, optimized image creation, and Docker Hub image distribution as part of my #90DaysOfDevOps journey.

---

## Tags

The repository was inspected through the **Tags** section.

Current image tag:

```text
v1
```

Docker image format:

```text
YOUR_USERNAME/go-multi-stage:v1
```

Here:

- `YOUR_USERNAME` = Docker Hub username
- `go-multi-stage` = repository name
- `v1` = image tag/version

---

## Pulling a Specific Tag

Command:

```bash
docker pull YOUR_USERNAME/go-multi-stage:v1
```

A specific tag points to a particular version of the image.

For example:

```text
v1 → Version 1
v2 → Version 2
v3 → Version 3
```

When `v1` is requested, Docker pulls the image associated with the `v1` tag.

---

## Pulling `latest`

Command:

```bash
docker pull YOUR_USERNAME/go-multi-stage:latest
```

The `latest` tag is a conventional tag that can point to whichever image is currently designated as `latest`.

For example:

```text
latest → v3
```

Later it could be changed to:

```text
latest → v4
```

The `v3` tag itself can remain unchanged.

### Important

`latest` does **not automatically mean the newest image**.

It is simply a tag named `latest`, and its target can change.

---

## Tag Comparison

| Tag | Meaning |
|---|---|
| `v1` | Specific version of the image |
| `v2` | Another specific version |
| `latest` | Image currently assigned the `latest` tag |

### Example

```text
YOUR_USERNAME/go-multi-stage:v1
```

means:

> Pull the image tagged `v1`.

```text
YOUR_USERNAME/go-multi-stage:latest
```

means:

> Pull the image currently tagged `latest`.

---

## Key Takeaway

Using version-specific tags such as `v1`, `v2`, and `v3` makes image versions explicit and reproducible.

The `latest` tag is convenient for development and simple deployments, but it can change over time and therefore does not guarantee a fixed image version.

---

# Task 5: Image Best Practices

## Objective

Apply Docker image best practices to create a smaller, safer and more production-ready image.

The following practices were applied:

1. Use a minimal base image
2. Run the application as a non-root user
3. Combine related `RUN` commands
4. Use specific image tags instead of `latest`

---

## Final Dockerfile

### Dockerfile.final

```dockerfile
# Stage 1: Build
FROM golang:1.24-alpine AS builder

WORKDIR /build

# Copy source code
COPY main.go .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o hello main.go


# Stage 2: Runtime
FROM alpine:3.22

# Create a non-root user and group
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

# Copy only the compiled binary
COPY --from=builder /build/hello .

# Change ownership
RUN chown appuser:appgroup /app/hello

# Run the container as a non-root user
USER appuser

CMD ["./hello"]
```

---

## Best Practice 1: Minimal Base Image

The final runtime image uses:

```dockerfile
FROM alpine:3.22
```

Alpine is a minimal Linux distribution designed to keep container images small.

Compared with a general-purpose Ubuntu image, Alpine provides a much smaller runtime environment when only basic Linux functionality is required.

### Comparison

| Base Image | Purpose |
|---|---|
| Ubuntu | General-purpose Linux distribution |
| Alpine | Minimal container-focused Linux distribution |

Using Alpine reduces unnecessary packages and keeps the runtime image smaller.

---

## Best Practice 2: Don't Run as Root

A dedicated user and group were created:

```dockerfile
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
```

The container then switches to:

```dockerfile
USER appuser
```

This means the application does not run with root privileges.

### Verification

Command:

```bash
docker run --rm go-final-stage:v1 whoami
```

Output:

```text
appuser
```

This reduces the potential impact of a container compromise.

---

## Best Practice 3: Combine RUN Commands

Related commands were combined:

```dockerfile
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
```

Instead of creating separate `RUN` instructions:

```dockerfile
RUN addgroup -S appgroup
RUN adduser -S appuser -G appgroup
```

Combining related commands can reduce unnecessary image layers and keeps the Dockerfile cleaner.

---

## Best Practice 4: Use Specific Base Image Tags

Instead of:

```dockerfile
FROM golang:latest
```

a specific tag is used:

```dockerfile
FROM golang:1.24-alpine
```

The runtime image also uses a specific version:

```dockerfile
FROM alpine:3.22
```

Using specific tags makes builds more predictable because the base image version is explicitly defined.

---

## Multi-Stage Build

The final Dockerfile continues to use a multi-stage build.

### Builder stage

```text
golang:1.24-alpine
        │
        ├── Go compiler
        ├── Go SDK
        └── Source code
                │
                ▼
          Compiled binary
```

### Runtime stage

```text
alpine:3.22
      │
      ├── Application binary
      └── Non-root user
```

The final image does not contain the Go compiler or SDK.

---

## Image Size Comparison

```bash
docker images
```

| Image | Tag | Size |
|---|---|---:|
| Single-stage | v1 | **1.22 GB** |
| Multi-stage | v1 | **16.3 MB** |
| Final optimized | v1 | **19.9 MB** |

---

## Final Verification

Build:

```bash
docker build -f Dockerfile.final -t go-final-stage:v1 .
```

Run:

```bash
docker run --rm go-final-stage:v1
```

Output:

```text
Hello from Day 35 - Go Docker!
```

Verify the user:

```bash
docker run --rm go-final-stage:v1 whoami
```

Output:

```text
appuser
```

---

## Best Practices Applied

| Practice | Implementation |
|---|---|
| Multi-stage build | `FROM ... AS builder` + `COPY --from=builder` |
| Minimal base image | `alpine:3.22` |
| Non-root user | `USER appuser` |
| Fewer layers | Combined related `RUN` commands |
| Fixed versions | `golang:1.24-alpine`, `alpine:3.22` |
| Small runtime | Only compiled Go binary copied |

---

## Key Takeaway

- A production Docker image should contain only what is required to run the application.

- The final image uses:

     **Build environment → Compile application → Minimal runtime → Non-root user**

- This makes the image smaller, more predictable and safer than the original single-stage image.

---
