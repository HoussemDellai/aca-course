# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Start from the latest golang base image
FROM golang:latest

# Set the Current Working Directory inside the container
WORKDIR /app

# Add files to app folder
ADD . /app

# Build the Go app
RUN go build -o main .

# Expose ports to the outside world
EXPOSE 3500

# Command to run the executable
CMD ["./main"]
