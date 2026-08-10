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
