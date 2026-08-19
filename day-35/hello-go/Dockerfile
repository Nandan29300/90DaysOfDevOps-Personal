
# Single-stage build using Go image

FROM golang:1.26

# Working directory
WORKDIR /app

# Copy source code
COPY main.go .

# Build the Go application
RUN go build -o hello main.go

# Run the application
CMD ["./hello"]
