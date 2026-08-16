# Use Python base image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy dependencies first
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Flask runs on port 5000
EXPOSE 5000

# Start the Flask app
CMD ["python", "app.py"]
