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
