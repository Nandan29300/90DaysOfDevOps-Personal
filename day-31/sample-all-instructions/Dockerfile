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
