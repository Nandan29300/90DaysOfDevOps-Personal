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
go-single-stage   v1        <your-size>
```

Image Size: `<your-size>`

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
docker build -f Dockerfile.multistage -t day35-go-multistage:v1 .
```

---

## Run Container

```bash
docker run --rm day35-go-multistage:v1
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
| day35-go-single | v1 | **638 MB** |
| day35-go-multistage | v1 | **255 MB** |

### Size Reduction

```text
638 MB - 255 MB = 383 MB
```

The multi-stage image is approximately **60% smaller** than the single-stage image.

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
YOUR_USERNAME/day35-go
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
day35-go-multistage:v1
```

was tagged for Docker Hub:

```bash
docker tag day35-go-multistage:v1 YOUR_USERNAME/day35-go:v1
```

Docker Hub image format:

```text
YOUR_USERNAME/day35-go:v1
```

---

## Push Image

```bash
docker push YOUR_USERNAME/day35-go:v1
```

The image was successfully uploaded to Docker Hub.

---

## Verify on Docker Hub

The repository was checked on Docker Hub.

Repository:

```text
YOUR_USERNAME/day35-go
```

Available tag:

```text
v1
```

---

## Pull Image

To verify that the image can be downloaded from Docker Hub:

```bash
docker pull YOUR_USERNAME/day35-go:v1
```

---

## Run Pulled Image

```bash
docker run --rm YOUR_USERNAME/day35-go:v1
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
