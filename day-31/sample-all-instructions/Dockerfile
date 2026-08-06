# Use official Python image as base image
FROM python:3.11-slim

# RUN: make a directory and add a file
RUN mkdir /app && echo "Sample File Content" > /app/sample.txt

# Copy application source code
COPY main.py /app/

# COPY: copy files from host into container
COPY sample.txt /app/

# Set the working directory
WORKDIR /app

# Install dependencies if required
# RUN pip install flask

# Document the application's port
EXPOSE 5000

# Default command
CMD ["python", "main.py"]
